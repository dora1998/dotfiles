---
name: fixloop
description: PRのCI・レビューをMonitorで継続監視し、CI失敗は修正、レビューはbot/AIなら妥当性を検証してから対応、人間/ActionsはそのままFixする
---

# fixloop — PR監視・自動修正ループ

現在のブランチに紐づくPRを `Monitor` ツールで継続監視し、CI失敗・新着レビューコメントを検知したら都度対応する。CronCreateによる定期実行ではなく、状態変化のみをイベントとして受け取るイベント駆動方式。

## 起動手順

### 1. 対象PRの特定

```bash
gh pr view --json number,url,headRefName,baseRepository
```

`$ARGUMENTS` にPR番号が指定された場合はそれを優先する。PRが存在しない場合は「対象PRが見つかりません」と伝えて中止する。

`{owner}` `{repo}` `{pr_number}` を控える。

### 2. Monitorループの起動

`Monitor` ツールを `persistent: true` で起動する。スクリプトは30秒ごとにGitHub APIをpollingし、**状態変化があったときだけ** 1行emitする。既存のコメント・CI状態は起動時にシードして通知対象外にする。

emitするイベント種別:

| プレフィックス | 発生条件 |
|---|---|
| `MONITOR_STARTED` | スクリプト起動時に1回 |
| `CI_FAILED` | チェック状態が変化し、FAILURE/ERRORが存在する |
| `CI_PASSED` | チェック状態が変化し、全て成功・PENDINGなし |
| `NEW_LINE_COMMENT` | 新着のPRレビュー行コメント |
| `NEW_REVIEW` | 新着のreview（approved / changes_requested / commented） |
| `NEW_COMMENT` | 新着のissue comment（PR本体への通常コメント） |
| `PR_CLOSED` | PRがclosed/mergedになった |
| `POLL_ERROR` | gh APIが連続失敗したとき（情報のみ） |

#### Monitor呼び出しテンプレ

`{owner}` `{repo}` `{pr_number}` を実際の値に置換してから呼ぶ。

```
Monitor({
  description: "PR #{pr_number} のCI・レビュー監視",
  persistent: true,
  timeout_ms: 3600000,
  command: <<下記スクリプト>>
})
```

#### Monitorスクリプト本体

```bash
set -u
PR={pr_number}
REPO={owner}/{repo}
STATE_DIR="$TMPDIR/fixloop-${PR}"
mkdir -p "$STATE_DIR"
SEEN_LINE="$STATE_DIR/line_comments"
SEEN_ISSUE="$STATE_DIR/issue_comments"
SEEN_REVIEW="$STATE_DIR/reviews"
LAST_CHECK="$STATE_DIR/checks"
LAST_PR_STATE="$STATE_DIR/pr_state"

seed() {
  gh api "repos/${REPO}/pulls/${PR}/comments" --paginate --jq '.[].id' 2>/dev/null | sort -u > "$SEEN_LINE" || true
  gh api "repos/${REPO}/issues/${PR}/comments" --paginate --jq '.[].id' 2>/dev/null | sort -u > "$SEEN_ISSUE" || true
  gh api "repos/${REPO}/pulls/${PR}/reviews" --paginate --jq '.[].id' 2>/dev/null | sort -u > "$SEEN_REVIEW" || true
  gh pr checks "$PR" --json name,state 2>/dev/null \
    | jq -r 'map("\(.name):\(.state)") | sort | join(",")' > "$LAST_CHECK" || true
  gh pr view "$PR" --json state 2>/dev/null | jq -r '.state' > "$LAST_PR_STATE" || true
}

seed
echo "MONITOR_STARTED: PR #${PR} (${REPO})"

err_streak=0
while true; do
  sleep 30

  # ---- PRの開閉状態
  pr_state=$(gh pr view "$PR" --json state 2>/dev/null | jq -r '.state' || echo "")
  if [ -n "$pr_state" ]; then
    prev_pr=$(cat "$LAST_PR_STATE" 2>/dev/null || echo "")
    if [ "$pr_state" != "$prev_pr" ] && [ "$pr_state" != "OPEN" ]; then
      echo "PR_CLOSED: PR #${PR} state=${pr_state}"
    fi
    echo "$pr_state" > "$LAST_PR_STATE"
  fi

  # ---- CI
  checks_json=$(gh pr checks "$PR" --json name,state 2>/dev/null || echo "")
  if [ -n "$checks_json" ]; then
    err_streak=0
    current=$(jq -r 'map("\(.name):\(.state)") | sort | join(",")' <<<"$checks_json")
    prev=$(cat "$LAST_CHECK" 2>/dev/null || echo "")
    if [ "$current" != "$prev" ]; then
      failed=$(jq -r '[.[] | select(.state=="FAILURE" or .state=="ERROR")] | length' <<<"$checks_json")
      pending=$(jq -r '[.[] | select(.state=="PENDING" or .state=="IN_PROGRESS" or .state=="QUEUED")] | length' <<<"$checks_json")
      if [ "$failed" -gt 0 ]; then
        names=$(jq -r '[.[] | select(.state=="FAILURE" or .state=="ERROR") | .name] | join(",")' <<<"$checks_json")
        echo "CI_FAILED: PR #${PR} failed=${failed} names=${names}"
      elif [ "$pending" -eq 0 ]; then
        echo "CI_PASSED: PR #${PR} all checks green"
      fi
      echo "$current" > "$LAST_CHECK"
    fi
  else
    err_streak=$((err_streak+1))
    [ "$err_streak" -ge 3 ] && echo "POLL_ERROR: gh pr checks failed (${err_streak}x)" && err_streak=0
  fi

  # ---- 行コメント (PR review comments)
  cur=$(gh api "repos/${REPO}/pulls/${PR}/comments" --paginate --jq '.[].id' 2>/dev/null | sort -u)
  if [ -n "$cur" ]; then
    for id in $(comm -23 <(echo "$cur") <(sort -u "$SEEN_LINE" 2>/dev/null)); do
      info=$(gh api "repos/${REPO}/pulls/comments/${id}" \
        --jq '"user=\(.user.login)|path=\(.path):\(.line // .original_line)|body=\(.body | gsub("\n";" ") | .[0:240])"' 2>/dev/null)
      echo "NEW_LINE_COMMENT: id=${id} ${info}"
    done
    echo "$cur" > "$SEEN_LINE"
  fi

  # ---- issue comments
  cur=$(gh api "repos/${REPO}/issues/${PR}/comments" --paginate --jq '.[].id' 2>/dev/null | sort -u)
  if [ -n "$cur" ]; then
    for id in $(comm -23 <(echo "$cur") <(sort -u "$SEEN_ISSUE" 2>/dev/null)); do
      info=$(gh api "repos/${REPO}/issues/comments/${id}" \
        --jq '"user=\(.user.login)|body=\(.body | gsub("\n";" ") | .[0:240])"' 2>/dev/null)
      echo "NEW_COMMENT: id=${id} ${info}"
    done
    echo "$cur" > "$SEEN_ISSUE"
  fi

  # ---- reviews
  cur=$(gh api "repos/${REPO}/pulls/${PR}/reviews" --paginate --jq '.[].id' 2>/dev/null | sort -u)
  if [ -n "$cur" ]; then
    for id in $(comm -23 <(echo "$cur") <(sort -u "$SEEN_REVIEW" 2>/dev/null)); do
      info=$(gh api "repos/${REPO}/pulls/${PR}/reviews/${id}" \
        --jq '"user=\(.user.login)|state=\(.state)|body=\((.body // "") | gsub("\n";" ") | .[0:240])"' 2>/dev/null)
      echo "NEW_REVIEW: id=${id} ${info}"
    done
    echo "$cur" > "$SEEN_REVIEW"
  fi
done
```

ポイント:
- `persistent: true` でセッション継続中ずっと監視する
- 初回 `seed()` で既存コメント/チェックをファイルに記録し、誤emit を防止
- 状態変化があった行だけ stdout に出力 → そのまま通知として届く
- `comm -23` で「新着のみ」を抽出
- gh API失敗時も `|| true` で監視ループを止めない
- 連続失敗時のみ `POLL_ERROR` を出して気付けるようにする

起動後、ユーザーには「Monitorで監視を開始しました。停止は `TaskStop` で行えます」と伝える。

---

## イベント受信時の対応

通知として届く1行を解析し、プレフィックスに応じて以下を実行する。

### CI_FAILED

1. **原因調査**
   - 失敗チェックの最新run ID を取得:
     ```bash
     gh pr checks {pr_number} --json name,state,link
     gh run list --branch {head_ref} --limit 5 --json databaseId,name,conclusion
     gh run view {run_id} --log-failed
     ```
   - エラーメッセージ・スタックトレースを解析し、関連ファイルを `Read` / `Grep` で調査
2. **修正**
   - 原因が特定できたらコードを修正
   - コミット＆プッシュ（リポジトリの規約に従ったメッセージ）:
     ```bash
     git add -p
     git commit -m "fix: {原因の要約}"
     git push
     ```
3. **修正できない場合**: ユーザーに状況を報告して判断を仰ぐ（Monitorは継続）

### CI_PASSED

進行中の対応がなければスキップしてOK。必要なら「全CI green」とだけ伝える。

### NEW_LINE_COMMENT / NEW_REVIEW / NEW_COMMENT

コメント本体は通知に短縮形で含まれるが、対応前に必ずフル本文を取得して読む:

```bash
# 行コメント
gh api "repos/{owner}/{repo}/pulls/comments/{id}"
# issue comment
gh api "repos/{owner}/{repo}/issues/comments/{id}"
# review
gh api "repos/{owner}/{repo}/pulls/{pr_number}/reviews/{id}"
```

その上でユーザー名により以下のルールで対応する。

#### 🤖 AI / Bot レビュアー（要妥当性検証）

対象ユーザー名に以下が含まれる場合:
- `claude` `anthropic`
- `devin`
- `greptile`
- `[bot]` サフィックス ※ただし `github-actions[bot]` は除く

**対応フロー:**
1. 指摘内容を読み、関連コードを `Read` / `Grep` でコードベース調査
2. 指摘が **妥当** と判断できる場合 → 修正してプッシュし、スレッド内で完了を返信:
   ```bash
   gh api "repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies" \
     -f body="対応しました。<!-- 🤖 replied by Claude -->"
   ```
3. 指摘が **不要・誤検知** と判断できる場合 → スレッド内で理由を返信し、スレッドをResolveする（修正はしない）:
   ```bash
   gh api "repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies" \
     -f body="調査しましたが、{理由のため} この指摘は適用しません。<!-- 🤖 replied by Claude -->"

   gh api graphql -f query='
     mutation {
       resolveReviewThread(input: { threadId: "{thread_node_id}" }) {
         thread { isResolved }
       }
     }
   '
   ```
   `thread_node_id` はPRのreviewThreadsから取得する:
   ```bash
   gh api graphql -f query='
     query {
       repository(owner: "{owner}", name: "{repo}") {
         pullRequest(number: {pr_number}) {
           reviewThreads(first: 100) {
             nodes { id isResolved comments(first: 1) { nodes { databaseId } } }
           }
         }
       }
     }
   '
   ```
   `comments.nodes[0].databaseId` が `comment_id` と一致するスレッドの `id` を使う。

#### 👤 人間のレビュアー / GitHub Actions

上記以外（人間のユーザー、`github-actions[bot]` 等）:

1. 指摘内容に従って素直に修正
2. 修正後コミット＆プッシュ
3. 対応したコメントの **スレッド内** でリプライ（`gh pr comment` ではなく必ずスレッド返信APIを使う）:
   ```bash
   gh api "repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies" \
     -f body="対応しました。<!-- 🤖 replied by Claude -->"
   ```

### PR_CLOSED

PRが close / merged された時点で監視は不要。`TaskStop` でMonitorを停止し、ユーザーに完了を伝える。

### POLL_ERROR

GitHub API が連続失敗。ネットワーク/認証を疑い、必要ならユーザーに状況を伝える。Monitor自体は継続する。

---

## 停止方法

ユーザーが「fixloop止めて」「stop fixloop」等と言ったら:

```
TaskStop({ task_id: <Monitor起動時に返ったID> })
```

停止後「fixloopを停止しました」と伝える。

---

## 注意事項

- 修正コミットのメッセージは各リポジトリの規約（CLAUDE.md等）に従う
- 同一コメントIDへの二重対応を避けるため、Monitor側で `comm -23` により新着のみ抽出している
- 通知が連発した場合でも、Monitorは200ms以内のstdout行を1通にまとめて配信する
- 重要な変化（CI失敗、人間からの新着review）を検知したときは、必要に応じて `PushNotification` でユーザーに即時通知する
- 監視中もユーザーからの他の指示には通常通り応答する（イベントは割り込みとして届く）

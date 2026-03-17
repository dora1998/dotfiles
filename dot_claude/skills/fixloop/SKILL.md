---
name: fixloop
description: PRのCI・レビューを1分毎に監視し、CI失敗は修正、レビューはbot/AIなら妥当性を検証してから対応、人間/ActionsはそのままFixする
---

# fixloop — PR監視・自動修正ループ

現在のブランチに紐づくPRを1分ごとに監視し、CI失敗・レビューコメントに自動対応する。

## 起動手順

### 1. 対象PRの特定

```bash
gh pr view --json number,url,headRefName
```

PRが存在しない場合は「対象PRが見つかりません」と伝えてループを開始しない。

### 2. 監視ループの開始

CronCreate ツールを使って以下のプロンプトを **1分間隔** で登録する（`{pr_number}` は実際の番号に置換）:

```
fixloop の監視サイクルを実行してください。対象PR: #{pr_number}
SKILL.md の「各サイクルで実行する処理」に従い、CI状態の確認・レビューコメントへの対応を行ってください。
```

ループ登録後、Cron IDをユーザーに伝える（停止時は `CronDelete` で削除できると案内する）。

---

## 各サイクルで実行する処理

### Step 1: 現在状態の取得（並列）

以下を並列で実行する:

```bash
# CI状態
gh pr checks --json name,state,completedAt,link

# 未解決レビューコメント（前回処理済みを除く）
gh pr view --json reviews,comments,reviewRequests
gh api "repos/{owner}/{repo}/pulls/{pr_number}/comments" --jq '.[] | {id, body, user: .user.login, created_at}'
```

### Step 2: CI失敗への対応

CIに `FAILURE` / `ERROR` のチェックが存在する場合:

1. **原因調査**
   - 失敗したチェックのログURLを取得:
     ```bash
     gh run view {run_id} --log-failed
     ```
   - エラーメッセージ・スタックトレースを解析する
   - 関連するソースファイルを `Read` / `Grep` で調査する

2. **修正**
   - 原因が特定できたらコードを修正する
   - 修正後コミット＆プッシュ:
     ```bash
     git add -p   # 差分を確認しながらステージ
     git commit -m "fix: {原因の要約}"
     git push
     ```

3. **修正できない場合**
   - ユーザーに状況を報告し、判断を仰ぐ（ループは継続）

### Step 3: レビューコメントへの対応

新着レビューコメントをユーザー名で分類し、以下のルールで対応する。

#### 🤖 AI / Bot レビュアー（要妥当性検証）

対象ユーザー名に以下が含まれる場合:
- `claude` `anthropic`
- `devin`
- `greptile`
- `[bot]` サフィックス ※ただし GitHub Actions は除く

**対応フロー:**
1. 指摘内容を読み、関連コードを `Read` / `Grep` でコードベース調査
2. 指摘が **妥当** と判断できる場合 → 修正してプッシュし、スレッド内で完了を返信する:
   ```bash
   gh api "repos/{owner}/{repo}/pulls/comments/{comment_id}/replies" \
     -f body="対応しました。"
   ```
3. 指摘が **不要・誤検知** と判断できる場合 → スレッド内で理由を返信し、スレッドをResolveする（修正はしない）:
   ```bash
   # スレッド内返信
   gh api "repos/{owner}/{repo}/pulls/comments/{comment_id}/replies" \
     -f body="調査しましたが、{理由のため} この指摘は適用しません。"

   # スレッドをResolve（review_thread IDを使用）
   gh api graphql -f query='
     mutation {
       resolveReviewThread(input: { threadId: "{thread_node_id}" }) {
         thread { isResolved }
       }
     }
   '
   ```
   thread_node_id は `gh api graphql` でPRのreviewThreadsから取得する:
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

上記以外のすべてのコメント（人間のユーザー、`github-actions[bot]` 等）:

**対応フロー:**
1. 指摘内容に従って素直に修正する
2. 修正後コミット＆プッシュ
3. 対応したコメントの**スレッド内**でリプライして完了を伝える（`gh pr comment` ではなく必ずスレッド返信APIを使う）:
   ```bash
   gh api "repos/{owner}/{repo}/pulls/comments/{comment_id}/replies" \
     -f body="対応しました。"
   ```

### Step 4: 状態レポート

各サイクル終了時に以下を簡潔に出力する:

```
[fixloop] {HH:MM} — CI: {✅PASS / ❌FAIL / ⏳PENDING} | 新着レビュー: {N}件対応 | 次回: 1分後
```

---

## 停止方法

ユーザーが「fixloop止めて」「stop fixloop」などと言ったら:

```bash
# 登録済みCronを確認して削除
CronList → 該当IDを CronDelete
```

削除後「fixloopを停止しました」と伝える。

---

## 注意事項

- 修正コミットのメッセージは各リポジトリの規約（CLAUDE.md等）に従う
- 同一コメントへの二重対応を避けるため、対応済みコメントIDをセッション内で記憶する
- `$ARGUMENTS` にPR番号が指定された場合はそのPRを対象にする（未指定時は現在ブランチのPR）
- CI・レビューがすべて正常でコメントもない場合はスキップして次サイクルへ

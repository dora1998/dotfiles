---
name: create-pull-request
description: 作業中の差分をコミットし、Draft PRを作成または更新する
disable-model-invocation: true
context: fork
---

# 差分コミット＆PR作成/更新

作業中の全差分を適切にコミットし、PRを作成または更新する。

## 処理フロー

### 1. ブランチ確認

- `git branch --show-current` で現在のブランチを確認
- `main`、`master` にいる場合、または detached HEAD の場合は、変更内容に応じた適切なブランチ名で新しいブランチを作成する
  ```bash
  git checkout -b {branch-name}
  ```

### 2. 状態確認（並列実行）

以下を並列で実行する:

- `git status` で変更を確認
- `git diff` でステージ済み・未ステージの差分を確認
- `git log --oneline -10` で直近のコミットメッセージスタイルを確認
- `gh pr list --head $(git branch --show-current)` で既存PRの有無を確認
- リポジトリのデフォルトブランチを `git remote show origin | grep 'HEAD branch'` で確認

### 3. コミット作成

- 変更内容に応じた適切なコミットメッセージを生成する
- コミットメッセージのフォーマットは各リポジトリのルール（CLAUDE.md等）に従う
- コミットメッセージは HEREDOC で渡す:
  ```bash
  git commit -m "$(cat <<'EOF'
  コミットメッセージ
  EOF
  )"
  ```

### 4. PR作成/更新

#### 既存PRがある場合

- `git push` のみ実行

#### 新規PRの場合

1. `git push -u origin $(git branch --show-current)` でリモートにpush
2. リポジトリに `.github/PULL_REQUEST_TEMPLATE.md` があればその書式に従ってPR本文を生成
3. PR本文の末尾に必ずセッション再開用コメントを付与:
   ```
   <!-- claude --resume ${CLAUDE_SESSION_ID} -->
   ```
4. Draft PRとして作成:
   ```bash
   gh pr create --draft --base {default-branch} --title "{title}" --body "$(cat <<'EOF'
   {PR本文}

   <!-- claude --resume ${CLAUDE_SESSION_ID} -->
   EOF
   )"
   ```
5. 作成されたPR URLを表示

## 注意事項

- ベースブランチはリモートのデフォルトブランチ（`main` or `master`）を使う
- `$ARGUMENTS` がある場合、PR本文に追加情報として含める
- PR概要を記述するときは、以下を心がける
  - 差分を読めばわかるファイルの変更内容は簡潔に
  - WhatよりWhyを書く。レビュワーがレビューしやすいPRを心がけ、実装した背景や関連するリソースへのリンクを含める。

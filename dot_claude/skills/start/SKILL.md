---
name: start
description: 新しいタスクを始めるためにブランチを作成する
---

新しいタスクを始めるために、最新のmainブランチから新しいブランチを作成する

## 処理フロー

### 1. ブランチ確認

- `git status` で変更を確認、差分がある場合は中断してユーザーにアクションを尋ねる
- `git branch --show-current` で現在のブランチを確認
- `main`、`master` にいる場合、または detached HEAD の場合は、Step 2のブランチ作成に進む

### 2. ブランチ作成

- リポジトリのデフォルトブランチを `git remote show origin | grep 'HEAD branch'` で確認
- ブランチ作成時は、必ずfetch後にリモートのデフォルトブランチから作成
  ```bash
  git fetch origin main
  git switch --no-track -c {branch-name} origin/main
  ```

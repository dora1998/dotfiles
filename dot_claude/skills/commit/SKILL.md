---
name: commit
description: Gitコミット時のルール。コミット、amend、force pushの判断基準を提供する。コードの修正・追加の実装が完了してコミットする際に使用する。
---

# Git Commit Rules

## レビュー状況に応じたコミット戦略

### セルフレビュー以外のレビューが1件以上ある場合

PRに対して自分以外のレビュアーからレビューが付いている場合、レビュー履歴を保護するため以下のルールに従う。

- **force pushは原則禁止**
  - 修正指示への対応: 新しいfixupコミットで対応する
  - 追加の実装指示: 別コミットで対応する
- **force pushが許可される例外**
  - `git commit --fixup` + `git rebase --autosquash` によるfixupコミットの整理
  - コンフリクト解消のためのrebase

### セルフレビュー以外のレビューがない場合

レビュー履歴がないため、コミット履歴を整理してよい。

- **修正指示への対応**: 直前のコミットをamendしてforce push (`--force-with-lease`)
- **追加の実装指示**: 別コミットとして追加する

## レビュー状況の確認方法

コミット前に以下のコマンドでレビュー状況を確認する:

```bash
gh pr view --json reviews --jq '[.reviews[] | select(.author.login != env.GH_USER and .state != "DISMISSED")] | length'
```

`$ARGUMENTS` が渡された場合はPR番号として使用する。

## PR概要の更新

コミット・push後、現在のブランチにPRが存在する場合は、変更内容に合わせてPR概要（body）も更新する。

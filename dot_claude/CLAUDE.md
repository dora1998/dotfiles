# Dependency / Supply Chain Policy

依存パッケージに関する提案・コード生成を行う場合や、依存パッケージを追加してプログラムを実行しようとする場合は、必ず以下を厳守すること。
（npm / yarn / pnpm / pip / poetry / cargo / bundler / composer / go modules など、すべてのパッケージマネージャに適用する）

- 依存パッケージのバージョンまたはハッシュ値は必ず固定すること。
  - 範囲指定（`^`, `~`, `>=`, `<` など）や `latest` / バージョン未指定は使用してはならない。
- 追加・更新するバージョンは、原則として **公開から少なくとも 7 日以上経過した安定版** を用いること。
- プロジェクトに lock ファイル（`package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` / `Pipfile.lock` / `Cargo.lock` / `Gemfile.lock` / `composer.lock` / `go.sum` など）が存在する場合は、**lock ファイルに記載されたバージョンを優先** し、それから逸脱しないこと。
- インストール時にスクリプトやフック（例: npm の `preinstall` / `install` / `postinstall` / `prepare`、Rust の `build.rs` など）が実行されるパッケージを**新規に導入することは避ける**こと。
  - 既に lock ファイルに記載されているもの、または既に使用中のものを同一メジャーバージョン内で更新する場合のみ例外とする。
- グローバル環境へのインストールは避けること。常にプロジェクトローカルへのインストールを行うこと。
- 公式レジストリ以外（任意の URL 指定、Git リポジトリ指定、ローカルパス指定など）からのパッケージインストールを提案してはならない。
- 上記ポリシーに違反するコード・コマンド（例: `npm install xxx@latest`、バージョン未指定の `pip install package-name`、グローバルインストールなど）は提示してはならない。

## GitHub Actions

タグではなくSHAで固定すること。また、Renovateが更新できるようにタグもコメントで併記すること。

```
# Good
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

# Bad
- uses: actions/checkout@v6
- uses: actions/checkout@v6.0.2
```

# Git Branch

- デフォルトブランチの main / master ブランチに対してrebaseやmergeを行うときは、必ずoriginのリモートブランチを参照すること
  - 誤操作防止のためにローカルブランチをつくっておらず、存在していても長らくpullしておらず古い場合が多い

# コードの書き方

- コミットメッセージやプルリクエストの概要は日本語で記述
- コードコメントを記述する際は、以下を遵守する
  - PRレビューのみに必要で、将来に渡って残す必要がない内容は書かない
  - TODOコメントを除き、チケット番号・PR番号などは書かない
  - コードのみを読んだだけでは推測しづらいコンテキストがある場合は書く

# aws-toolbox

AWS で「そのまま使える」コード(Terraform、JSON、スクリプト、クエリ)を溜めて再利用するリポジトリ。
全体の書き方ルールは README.md を参照する。

## 収録物を追加するとき

- 用途ごとにサブフォルダを作る(例: `json/iam-policies/s3-live-replication/`)
- バリエーションがある場合は、軸の組み合わせをファイル名で表して揃える
  - 例: `bidirectional-cross-account.json` / `one-way-same-account.json`
- 渡された実環境の値(バケット名、アカウント ID など)は必ずプレースホルダーに置き換える
  - 方向の区別がないものは `${BUCKET_A}` / `${BUCKET_B}`、あるものは `${SOURCE_BUCKET}` / `${DESTINATION_BUCKET}` のように意味の分かる名前にする
- JSON のインデントは 2 スペース
- リポジトリ直下の README.md には収録物の一覧を置かない(手作業での追記をやめたため)

## サブフォルダの README.md

できるだけ最小限にする。次の形を基本とする。

```markdown
# <日本語のタイトル(パス形式にしない)>

<用途を 1 行>

前提条件: <あれば 1 行>

| ファイル | <分類軸> | <分類軸> |
| --- | --- | --- |
| `xxx.json` | ... | ... |

- <注意事項を 1 行ずつ>
```

- 使い方のコマンド例やプレースホルダーの説明は書かない
- 項目が増えても表に 1 行足すだけで済む形にする
- 参考 URL を書く場合は、開いて確認していないページのタイトルを推測で書かない

## チェック

- pre-commit と tflint は使わない(ローカルに導入しない方針)
- CI(`.github/workflows/lint.yml`)で JSON / YAML の構文、terraform fmt / validate、shellcheck、ruff、gitleaks を実行する
- ローカルに ruff がないため、Python は ruff format の行長 88 を意識して書く
- Claude Code の hook(`.claude/settings.json`、スクリプトは `.claude/hooks/`)
  - 書き込み前: アカウント ID、プレースホルダーでない ARN、アクセスキーを検出してブロックする
  - 書き込み後: JSON / Python の構文、`bash -n`、`terraform fmt` を実行する
  - プロンプトに「マージ」を含むとき、または `gh pr merge` の実行後: マージ済みブランチをリモートとローカルから削除し、main を最新化する
- PR をマージするときは `gh pr merge <番号> --squash` だけを実行し、ブランチの削除と main の最新化は hook に任せる

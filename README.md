# aws-toolbox

AWS で「そのまま使える」コードを溜め込んで再利用するためのリポジトリです。
Terraform モジュール、JSON(IAM ポリシー、SCP など)、運用スクリプト、ログのクエリを収録します。

## フォルダ構成

```
aws-toolbox/
├── terraform/
│   ├── modules/          # 再利用可能な Terraform モジュール
│   │   └── _template/    # モジュールのひな形
│   └── examples/         # モジュールの使用例
├── json/
│   ├── iam-policies/           # IAM ポリシー
│   ├── scp/                    # サービスコントロールポリシー
│   ├── eventbridge-patterns/   # EventBridge のイベントパターン
│   ├── cloudwatch-dashboards/  # CloudWatch ダッシュボードの定義
│   └── step-functions/         # Step Functions のステートマシン定義
├── scripts/
│   ├── bash/             # Bash(AWS CLI)スクリプト
│   └── python/           # Python(boto3)スクリプト
└── queries/
    └── logs-insights/    # CloudWatch Logs Insights のクエリ
```

## フォルダごとの役割と使い方

### terraform/

- `modules/`: 再利用可能なモジュールを置きます。新規作成時は `_template/` をコピーします。

  ```bash
  cp -r terraform/modules/_template terraform/modules/<module-name>
  ```

- `examples/`: モジュールを呼び出す使用例(ルートモジュール)を置きます。

  ```bash
  cd terraform/examples/<example-name>
  terraform init
  terraform plan -var-file=<your>.tfvars
  ```

### json/

IAM ポリシーや SCP などの JSON を置きます。アカウント固有の値はプレースホルダーになっているので、`envsubst` で置換してから使います(後述)。

### scripts/

- `bash/`: AWS CLI を使う Bash スクリプト。`_template.sh` をコピーして作成します。
- `python/`: boto3 を使う Python スクリプト。`_template.py` をコピーして作成します。

どちらもデフォルトは dry-run で、`--execute` を付けたときだけ実際に処理します。

```bash
./scripts/bash/<script-name>.sh --profile dev --region ap-northeast-1            # dry-run
./scripts/bash/<script-name>.sh --profile dev --region ap-northeast-1 --execute  # 実行

pip install -r scripts/python/requirements.txt
python3 scripts/python/<script_name>.py --profile dev --region ap-northeast-1 --execute
```

### queries/

CloudWatch Logs Insights のクエリを置きます。コンソールに貼り付けるか、`aws logs start-query` で実行します。

## 書き方ルール

- アカウント ID、ARN、認証情報は直接書かない。JSON では `${ACCOUNT_ID}` のようなプレースホルダーにする
- Terraform の値は直接書かず、`variables.tf` に出す
- 削除や変更を行うスクリプトは dry-run をデフォルトにする
- ファイル名とフォルダ名は英小文字とハイフン(Python ファイルはアンダースコアも可)
- 各フォルダに README.md を置き、用途を書く

## JSON のプレースホルダーの置換

JSON 内のプレースホルダー(`${ACCOUNT_ID}`、`${REGION}` など)は `envsubst` で置換します。

例: `json/iam-policies/s3-read-only-specific-bucket.json`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::${BUCKET_NAME}",
        "arn:aws:s3:::${BUCKET_NAME}/*"
      ],
      "Condition": {
        "StringEquals": { "aws:ResourceAccount": "${ACCOUNT_ID}" }
      }
    }
  ]
}
```

```bash
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export BUCKET_NAME="my-bucket"

# 置換する変数を明示する(JSON 内の他の $ 記号を誤って置換しないため)
envsubst '${ACCOUNT_ID} ${BUCKET_NAME}' \
  < json/iam-policies/s3-read-only-specific-bucket.json \
  > /tmp/policy.json

aws iam create-policy \
  --policy-name s3-read-only-my-bucket \
  --policy-document file:///tmp/policy.json
```

`envsubst` は macOS では `brew install gettext` でインストールできます。

## チェック(CI)

push と Pull Request のたびに GitHub Actions(`.github/workflows/lint.yml`)で次のチェックを実行します。

| チェック | 対象 |
| --- | --- |
| JSON / YAML の構文 | `*.json`、`*.yml`、`*.yaml` |
| `terraform fmt -check` / `terraform validate` | `*.tf` |
| shellcheck | `*.sh` |
| ruff(lint / format) | `*.py` |
| gitleaks(シークレット検出) | リポジトリの全履歴 |

ローカルで同じチェックを実行したい場合は、各ツールを直接実行します(例: `terraform fmt -recursive`、`ruff format .`)。

## 収録物の一覧

追加したら、カテゴリごとの表に 1 行ずつ追記してください。

### Terraform モジュール

| 名前 | 概要 |
| --- | --- |
| (なし) | |

### JSON

| ファイル | 概要 |
| --- | --- |
| (なし) | |

### スクリプト

| ファイル | 概要 | dry-run |
| --- | --- | --- |
| (なし) | | |

### クエリ

| ファイル | 概要 |
| --- | --- |
| (なし) | |

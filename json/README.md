# json

IAM ポリシーや SCP など、AWS で使う JSON を置くフォルダです。

アカウント ID、ARN、リージョンなどは直接書かず、`${ACCOUNT_ID}` のようなプレースホルダーにしてください。
使うときは `envsubst` で置換します(使い方はリポジトリ直下の README.md を参照)。

| フォルダ | 用途 |
| --- | --- |
| `iam-policies/` | IAM ポリシー(アイデンティティベース / リソースベース / 信頼ポリシー) |
| `scp/` | AWS Organizations のサービスコントロールポリシー |
| `eventbridge-patterns/` | EventBridge ルールのイベントパターン |
| `cloudwatch-dashboards/` | CloudWatch ダッシュボードの定義(dashboard body) |
| `step-functions/` | Step Functions のステートマシン定義(ASL) |

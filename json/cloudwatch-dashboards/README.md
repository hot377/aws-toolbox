# json/cloudwatch-dashboards

CloudWatch ダッシュボードの定義(dashboard body)の JSON を置くフォルダです。

- ファイル名の例: `lambda-overview.json`、`alb-overview.json`
- 登録: `aws cloudwatch put-dashboard --dashboard-name <name> --dashboard-body file://<file>`

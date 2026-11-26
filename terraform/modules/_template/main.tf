# ------------------------------------------------------------------------------
# モジュールのひな形
#
# 書き方のルール
# - アカウント ID、ARN、認証情報は直接書かない
#   - アカウント ID やリージョンが必要なら data "aws_caller_identity" / data "aws_region" で取得する
#   - その他の値は variables.tf に変数として出す
# - provider ブロックはモジュール内に書かない(呼び出し側で設定する)
# - リソース名は local.name を接頭辞にし、タグは local.tags を付ける
#
# 例:
# resource "aws_s3_bucket" "this" {
#   bucket = "${local.name}-example"
#   tags   = local.tags
# }
# ------------------------------------------------------------------------------

locals {
  name = var.name_prefix

  tags = merge(
    var.tags,
    {
      ManagedBy = "terraform"
    },
  )
}

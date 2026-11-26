# すべての変数に description と type を付ける。
# 値(名前、CIDR、ARN など)は main.tf に直接書かず、ここに変数として出す。

variable "name_prefix" {
  description = "作成するリソース名の接頭辞(例: myapp-dev)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix は英小文字、数字、ハイフンのみ使用できます。"
  }
}

variable "tags" {
  description = "すべてのリソースに付与するタグ"
  type        = map(string)
  default     = {}
}

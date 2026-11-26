# 出力にも description を付ける。

output "name_prefix" {
  description = "このモジュールで使用したリソース名の接頭辞"
  value       = local.name
}

# _template

Terraform モジュールのひな形です。新しいモジュールを作るときはこのフォルダをコピーしてください。

```bash
cp -r terraform/modules/_template terraform/modules/<module-name>
```

## 概要

(モジュールが作成するリソースと用途を書く)

## 使用例

```hcl
module "example" {
  source = "../../modules/<module-name>"

  name_prefix = var.name_prefix
  tags        = var.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | 作成するリソース名の接頭辞(例: myapp-dev) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | すべてのリソースに付与するタグ | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | このモジュールで使用したリソース名の接頭辞 |
<!-- END_TF_DOCS -->

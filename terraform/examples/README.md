# terraform/examples

`terraform/modules/` のモジュールを使った使用例(ルートモジュール)を置くフォルダです。

- 1 つの例につき 1 フォルダ(例: `examples/s3-private-bucket-basic/`)
- 値は `variables.tf` に出し、`terraform.tfvars` はコミットしない(`.gitignore` で除外済み)
- 必要なら `terraform.tfvars.example` を置いて値の例を示す

# terraform

Terraform のモジュールと使用例を置くフォルダです。

- `modules/`: 再利用可能なモジュール。新規作成時は `modules/_template/` をコピーする
- `examples/`: モジュールを組み合わせた使用例(ルートモジュール)

値は直接書かず、すべて `variables.tf` に出してください。

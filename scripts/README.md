# scripts

運用で使うスクリプトを置くフォルダです。

| フォルダ | 用途 |
| --- | --- |
| `bash/` | Bash(AWS CLI)スクリプト。`_template.sh` をコピーして作成する |
| `python/` | Python(boto3)スクリプト。`_template.py` をコピーして作成する |

削除や変更を行うスクリプトは dry-run をデフォルトにし、`--execute` を付けたときだけ実際に処理してください。

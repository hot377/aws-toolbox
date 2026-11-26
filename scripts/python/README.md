# scripts/python

Python(boto3)スクリプトを置くフォルダです。

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r scripts/python/requirements.txt
cp scripts/python/_template.py scripts/python/<script_name>.py
```

- ファイル名は英小文字とアンダースコア(またはハイフン)(例: `delete_old_snapshots.py`)
- 冒頭の docstring に「概要 / 使い方 / 必要な IAM 権限」を書く
- ruff(lint / format)の指摘をなくす

# scripts/bash

Bash(AWS CLI)スクリプトを置くフォルダです。

```bash
cp scripts/bash/_template.sh scripts/bash/<script-name>.sh
chmod +x scripts/bash/<script-name>.sh
```

- ファイル名は英小文字とハイフン(例: `delete-unattached-ebs-volumes.sh`)
- 冒頭に「概要 / 使い方 / 必要な IAM 権限」を書く
- shellcheck の警告をなくす

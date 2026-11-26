# S3 ライブレプリケーション

S3 のライブレプリケーション(CRR / SRR)用ロールのアクセス許可ポリシー。

前提条件: 元・先の両バケットでバージョニングが有効であること。

| ファイル | 方向 | アカウント |
| --- | --- | --- |
| `bidirectional-cross-account.json` | 双方向 | 別アカウント |
| `bidirectional-same-account.json` | 双方向 | 同一アカウント |
| `one-way-cross-account.json` | 片方向 | 別アカウント |
| `one-way-same-account.json` | 片方向 | 同一アカウント |

- 別アカウントの場合、レプリケーション先のバケットポリシーで元アカウントのロールに `s3:ReplicateObject` などを許可する必要がある
- `s3:GetObjectRetention` / `s3:GetObjectLegalHold` はオブジェクトロックを考慮して入れている(先バケットでもオブジェクトロックの有効化が必要)

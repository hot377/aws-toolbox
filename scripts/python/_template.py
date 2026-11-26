#!/usr/bin/env python3
"""(このスクリプトが何をするかを 1 行で書く)

概要:
    (処理の内容を書く)
    例: 指定リージョンの未使用 EBS ボリュームを削除する

使い方:
    python3 _template.py [--profile PROFILE] [--region REGION] [--dry-run | --execute]

    デフォルトは dry-run(何も変更しない)。--execute を付けたときだけ実際に処理する。

    例:
        python3 _template.py --profile dev --region ap-northeast-1            # dry-run
        python3 _template.py --profile dev --region ap-northeast-1 --execute  # 実行

必要な IAM 権限:
    - sts:GetCallerIdentity
    - (スクリプトで使う権限を列挙する。例: ec2:DescribeVolumes, ec2:DeleteVolume)
"""

from __future__ import annotations

import argparse
import logging
import sys

import boto3

logger = logging.getLogger(__name__)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """コマンドライン引数を解析する。"""
    parser = argparse.ArgumentParser(
        description=__doc__.splitlines()[0],
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--profile", help="使用する AWS のプロファイル")
    parser.add_argument("--region", help="対象のリージョン")

    mode = parser.add_mutually_exclusive_group()
    mode.add_argument(
        "--dry-run",
        dest="dry_run",
        action="store_true",
        default=True,
        help="実際には処理せず、実行内容だけを表示する(デフォルト)",
    )
    mode.add_argument(
        "--execute",
        dest="dry_run",
        action="store_false",
        help="実際に処理する",
    )

    parser.add_argument(
        "-v", "--verbose", action="store_true", help="デバッグログを出力する"
    )
    return parser.parse_args(argv)


def run(session: boto3.Session, dry_run: bool) -> None:
    """メインの処理。

    参照系はそのまま実行し、削除や変更は dry_run を確認してから実行する。
    """
    account_id = session.client("sts").get_caller_identity()["Account"]
    logger.info(
        "対象アカウント: %s / リージョン: %s / dry-run: %s",
        account_id,
        session.region_name,
        dry_run,
    )

    # ---- ここに処理を書く ----
    # 例:
    # ec2 = session.client("ec2")
    # for volume in ...:
    #     if dry_run:
    #         logger.info("[DRY-RUN] ボリュームを削除します: %s", volume_id)
    #         continue
    #     ec2.delete_volume(VolumeId=volume_id)
    #     logger.info("[EXECUTE] ボリュームを削除しました: %s", volume_id)

    if dry_run:
        logger.info(
            "dry-run のため変更は行っていません。"
            "実行するには --execute を付けてください。"
        )


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )
    # boto3 / botocore のデバッグログは量が多いため抑制する
    logging.getLogger("botocore").setLevel(logging.WARNING)
    logging.getLogger("urllib3").setLevel(logging.WARNING)

    session = boto3.Session(profile_name=args.profile, region_name=args.region)
    try:
        run(session, dry_run=args.dry_run)
    except Exception:
        logger.exception("処理に失敗しました")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

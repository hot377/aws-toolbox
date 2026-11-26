#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# 概要:
#   (このスクリプトが何をするかを書く)
#   例: 指定リージョンの未使用 EBS ボリュームを削除する
#
# 使い方:
#   ./_template.sh [--profile PROFILE] [--region REGION] [--dry-run | --execute]
#
#   デフォルトは dry-run(何も変更しない)。--execute を付けたときだけ実際に処理する。
#
#   例:
#     ./_template.sh --profile dev --region ap-northeast-1            # dry-run
#     ./_template.sh --profile dev --region ap-northeast-1 --execute  # 実行
#
# 必要な IAM 権限:
#   - sts:GetCallerIdentity
#   - (スクリプトで使う権限を列挙する。例: ec2:DescribeVolumes, ec2:DeleteVolume)
# ------------------------------------------------------------------------------
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

DRY_RUN=true

usage() {
  cat <<USAGE
Usage: ${SCRIPT_NAME} [options]

Options:
  --profile PROFILE  使用する AWS CLI のプロファイル
  --region REGION    対象のリージョン
  --dry-run          実際には処理せず、実行内容だけを表示する(デフォルト)
  --execute          実際に処理する
  -h, --help         このヘルプを表示する
USAGE
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

die() {
  log "ERROR: $*"
  exit 1
}

# dry-run のときはコマンドを表示するだけにし、--execute のときだけ実行する
run() {
  if [[ "${DRY_RUN}" == true ]]; then
    log "[DRY-RUN] $*"
  else
    log "[EXECUTE] $*"
    "$@"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        [[ $# -ge 2 ]] || die "--profile には値が必要です"
        export AWS_PROFILE="$2"
        shift 2
        ;;
      --region)
        [[ $# -ge 2 ]] || die "--region には値が必要です"
        export AWS_DEFAULT_REGION="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --execute)
        DRY_RUN=false
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        die "不明な引数です: $1"
        ;;
    esac
  done
}

main() {
  parse_args "$@"

  command -v aws >/dev/null 2>&1 || die "aws コマンドが見つかりません"

  local account_id
  account_id="$(aws sts get-caller-identity --query Account --output text)"
  log "対象アカウント: ${account_id} / dry-run: ${DRY_RUN}"

  # ---- ここに処理を書く ----
  # --profile / --region は環境変数 AWS_PROFILE / AWS_DEFAULT_REGION に設定済み。
  # 参照系はそのまま実行し、削除や変更は run 経由で実行する。
  # 例:
  #   run aws ec2 delete-volume --volume-id "${volume_id}"

  if [[ "${DRY_RUN}" == true ]]; then
    log "dry-run のため変更は行っていません。実行するには --execute を付けてください。"
  fi
}

main "$@"

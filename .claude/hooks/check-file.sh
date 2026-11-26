#!/usr/bin/env bash
# PostToolUse(Write / Edit)で、書き込んだファイルを拡張子ごとにチェックする。
#   .json: 構文チェック
#   .tf  : terraform fmt(自動整形)
#   .sh  : bash -n
#   .py  : 構文チェック
# 失敗した場合は decision: block で Claude に修正を促す。
set -uo pipefail

file="$(python3 -c 'import json, sys; d = json.load(sys.stdin); print((d.get("tool_input") or {}).get("file_path", ""))')"
[[ -n "${file}" && -f "${file}" ]] || exit 0

case "${file}" in
  *.json) output="$(python3 -m json.tool "${file}" 2>&1 >/dev/null)" ;;
  *.tf) output="$(terraform fmt "${file}" 2>&1 >/dev/null)" ;;
  *.sh) output="$(bash -n "${file}" 2>&1)" ;;
  *.py) output="$(python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read(), sys.argv[1])' "${file}" 2>&1)" ;;
  *) exit 0 ;;
esac
status=$?

if [[ ${status} -ne 0 ]]; then
  python3 -c 'import json, sys; print(json.dumps({"decision": "block", "reason": f"{sys.argv[1]} のチェックに失敗しました:\n{sys.argv[2]}"}, ensure_ascii=False))' \
    "${file}" "${output}"
fi
exit 0

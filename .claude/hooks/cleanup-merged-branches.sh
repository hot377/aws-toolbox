#!/usr/bin/env bash
# UserPromptSubmit で、プロンプトに「マージ」を含むときにマージ済みブランチを掃除する。
#   1. main に切り替えて git pull --rebase で最新化する
#   2. PR がマージ済み、かつローカルの先頭コミットが PR の最終コミットと一致するブランチだけを
#      リモートとローカルから削除する(マージ後に追加したコミットがあるブランチは残す)
# 結果は additionalContext で Claude に伝える。
set -uo pipefail

prompt="$(python3 -c 'import json, sys; print(json.load(sys.stdin).get("prompt", ""))')"
[[ "${prompt}" == *マージ* ]] || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
command -v gh >/dev/null 2>&1 || exit 0

log=()

# 未コミットの変更があるときは何もしない
if [[ -n "$(git status --porcelain)" ]]; then
  log+=("未コミットの変更があるため、ブランチ掃除をスキップしました。")
else
  git fetch --prune --quiet origin
  for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    [[ "${branch}" == "main" ]] && continue

    merged_head="$(gh pr list --state merged --head "${branch}" --json headRefOid --jq '.[0].headRefOid // empty' 2>/dev/null)"
    [[ -n "${merged_head}" ]] || continue

    if [[ "$(git rev-parse "${branch}")" != "${merged_head}" ]]; then
      log+=("${branch}: マージ後のコミットがあるため残しました。")
      continue
    fi

    [[ "$(git branch --show-current)" == "${branch}" ]] && git checkout --quiet main
    if git ls-remote --exit-code --heads origin "${branch}" >/dev/null 2>&1; then
      git push --quiet origin --delete "${branch}" && log+=("${branch}: リモートから削除しました。")
    fi
    git branch --quiet -D "${branch}" && log+=("${branch}: ローカルから削除しました。")
  done

  if [[ "$(git branch --show-current)" == "main" ]]; then
    git pull --rebase --quiet && log+=("main を git pull --rebase で最新化しました。")
  fi
fi

[[ ${#log[@]} -gt 0 ]] || exit 0
python3 -c 'import json, sys; print(json.dumps({"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "ブランチ掃除 hook の結果:\n" + "\n".join(sys.argv[1:])}}, ensure_ascii=False))' \
  "${log[@]}"
exit 0

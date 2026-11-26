#!/usr/bin/env python3
"""PreToolUse(Write / Edit)で、プレースホルダー化漏れを検出してブロックする。

検出対象:
    - 12 桁のアカウント ID
    - プレースホルダー(${...})を含まない ARN
      (AWS 管理ポリシー arn:aws:iam::aws:policy/... とワイルドカードのみの ARN は除く)
    - アクセスキー ID(AKIA / ASIA で始まる 20 文字)
"""

from __future__ import annotations

import json
import re
import sys

ACCOUNT_ID = re.compile(r"(?<![0-9])[0-9]{12}(?![0-9])")
ARN = re.compile(r"arn:aws[a-z-]*:[^\s\"',)\]}]*")
ACCESS_KEY = re.compile(r"(?<![A-Z0-9])(?:AKIA|ASIA)[A-Z0-9]{16}(?![A-Z0-9])")

# 判定から除く ARN(AWS 管理ポリシーなど、アカウント固有でないもの)
ALLOWED_ARN = re.compile(r"^arn:aws[a-z-]*:iam::aws:policy/")
# 判定から除くファイル(この hook 自身)
SKIP_PATH = re.compile(r"/\.claude/hooks/")


def collect_text(tool_input: dict) -> str:
    """書き込まれる内容を取り出す。"""
    if "content" in tool_input:
        return tool_input["content"]
    if "new_string" in tool_input:
        return tool_input["new_string"]
    edits = tool_input.get("edits") or []
    return "\n".join(e.get("new_string", "") for e in edits)


def is_placeholder_arn(arn: str) -> bool:
    if "${" in arn or ALLOWED_ARN.match(arn):
        return True
    # arn:aws:s3:::* のように、サービス以降が空・ワイルドカードだけのもの
    rest = arn.split(":", 3)[-1]
    return re.fullmatch(r"[:*/]*", rest) is not None


def find_issues(text: str) -> list[str]:
    issues = []
    for m in ACCESS_KEY.findall(text):
        issues.append(f"アクセスキー ID: {m[:4]}****")
    for arn in ARN.findall(text):
        if not is_placeholder_arn(arn):
            issues.append(f"ARN: {arn}")
    # ARN 内のアカウント ID は ARN 側で検出済みなので、ARN を除いてから探す
    for m in ACCOUNT_ID.findall(ARN.sub("", text)):
        issues.append(f"アカウント ID の可能性: {m}")
    return issues


def main() -> int:
    payload = json.load(sys.stdin)
    tool_input = payload.get("tool_input") or {}
    if SKIP_PATH.search(tool_input.get("file_path", "")):
        return 0

    issues = find_issues(collect_text(tool_input))
    if not issues:
        return 0

    reason = (
        "アカウント ID、ARN、認証情報は直接書かず、${ACCOUNT_ID} のような"
        "プレースホルダーにしてください。検出: " + " / ".join(sorted(set(issues)))
    )
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())

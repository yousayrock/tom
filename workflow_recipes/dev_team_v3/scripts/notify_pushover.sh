#!/usr/bin/env bash
# Human Gate通知をPushoverへ送る。
# DEV_TEAM_V3_SPEC.md #14 Failure Handling / #2 Human Gate:
# 同じ失敗が既定3回続いたら停止し、ユーザーへ判断を委ねる。その通知に使う。
#
# 認証情報はリポジトリに含めず、goose-webui (~/000/apps/goose-webui) と同じ
# ~/.config/goose/pushover.env から読む (PUSHOVER_USER_KEY / PUSHOVER_API_TOKEN)。
# ファイルが無い/キー未設定の場合は何もせず終了する（通知はあくまでbest-effort）。
#
# Usage: notify_pushover.sh "<title>" "<message>"

set -euo pipefail

TITLE="${1:-トム Dev Team V3 Human Gate}"
MESSAGE="${2:-3回失敗したため停止しました。詳細はセッションを確認してください。}"

ENV_FILE="${PUSHOVER_ENV_FILE:-$HOME/.config/goose/pushover.env}"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  set -a
  source "$ENV_FILE"
  set +a
fi

if [ -z "${PUSHOVER_USER_KEY:-}" ] || [ -z "${PUSHOVER_API_TOKEN:-}" ]; then
  echo "pushover.env が無い、または未設定のため通知をスキップします（best-effort）。" >&2
  exit 0
fi

# メッセージはPushoverの上限(1024文字)に合わせて切り詰める。
MESSAGE="${MESSAGE:0:1024}"

curl -sS \
  --max-time 10 \
  --form-string "token=${PUSHOVER_API_TOKEN}" \
  --form-string "user=${PUSHOVER_USER_KEY}" \
  --form-string "title=${TITLE}" \
  --form-string "message=${MESSAGE}" \
  https://api.pushover.net/1/messages.json >/dev/null \
  || echo "Pushover通知の送信に失敗しました（処理は継続します）。" >&2

exit 0

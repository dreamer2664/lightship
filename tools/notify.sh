#!/usr/bin/env bash
# notify.sh — send a one-line status to everyone on the contact wire.
#
# ntfy (recommended): topic is public in the repo on purpose — a topic name is
# not a credential. Override per-agent with NTFY_TOPIC if you want a private wire.
#
# telegram (alternative): set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID.
# No secrets in this file.
set -euo pipefail

MSG="${1:?usage: notify.sh <message>}"
NTFY_TOPIC="${NTFY_TOPIC:-lightship}"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

SENT=0

if [[ -n "$NTFY_TOPIC" ]]; then
    curl -s -d "$MSG" "https://ntfy.sh/${NTFY_TOPIC}" >/dev/null 2>&1 && SENT=1
    echo "notify: sent to ntfy topic ${NTFY_TOPIC}" >&2
fi

if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" -d "text=${MSG}" >/dev/null 2>&1 && SENT=1
    echo "notify: sent to telegram chat ${TELEGRAM_CHAT_ID}" >&2
fi

if [[ $SENT -eq 0 ]]; then
    echo "notify: no contact wire configured (set NTFY_TOPIC or TELEGRAM_*)" >&2
    echo "notify: message would have been: $MSG" >&2
    exit 1
fi

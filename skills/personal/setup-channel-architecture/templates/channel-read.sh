#!/usr/bin/env bash
# Read recent channel messages.
#
# Usage:
#   .channel/read.sh                  # last 10 of any type, open or closed
#   .channel/read.sh handoff          # last 10 handoffs
#   .channel/read.sh handoff 5        # last 5 handoffs
#   .channel/read.sh note 20 closed   # last 20 closed notes

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/config"

type="${1:-}"
limit="${2:-10}"
state="${3:-all}"

if [[ -z "${CHANNEL_REPO:-}" ]]; then
  echo "error: CHANNEL_REPO is not set in .channel/config" >&2
  exit 1
fi

labels="channel"
if [[ -n "$type" ]]; then
  case "$type" in
    handoff|decision|note) labels="$labels,type:$type" ;;
    *) echo "error: type must be one of: handoff, decision, note" >&2; exit 2 ;;
  esac
fi

gh issue list \
  --repo "$CHANNEL_REPO" \
  --label "$labels" \
  --state "$state" \
  --limit "$limit" \
  --json number,title,state,labels,createdAt,url \
  --template '{{range .}}#{{.number}}  {{.state}}  {{.createdAt | timeago}}  {{.title}}
  {{.url}}
{{end}}'

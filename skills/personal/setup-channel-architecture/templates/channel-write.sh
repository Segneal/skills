#!/usr/bin/env bash
# Write a message to the channel.
#
# Usage:
#   .channel/write.sh <type> <title> [<body-file>]
#   .channel/write.sh <type> <title> < body.md
#   .channel/write.sh <type> <title> <<<"inline body"
#
# <type> ∈ {handoff, decision, note}

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/config"

if [[ $# -lt 2 ]]; then
  echo "usage: $(basename "$0") <handoff|decision|note> <title> [<body-file>]" >&2
  exit 2
fi

type="$1"
title="$2"
body_src="${3:-/dev/stdin}"

case "$type" in
  handoff|decision|note) ;;
  *) echo "error: type must be one of: handoff, decision, note" >&2; exit 2 ;;
esac

if [[ -z "${CHANNEL_REPO:-}" ]]; then
  echo "error: CHANNEL_REPO is not set in .channel/config" >&2
  exit 1
fi

body="$(cat "$body_src")"

labels="channel,type:$type"
if [[ "$type" == "handoff" ]]; then
  labels="$labels,status:open"
fi

gh issue create \
  --repo "$CHANNEL_REPO" \
  --title "[$type] $title" \
  --body "$body" \
  --label "$labels"

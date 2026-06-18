#!/usr/bin/env bash
# SessionStart hook: surface the latest open handoff (if any) into the
# Claude session context. Output goes to stdout and is injected as
# system context.

set -euo pipefail

# Locate config relative to this script.
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config="$here/config"

# Fail silently if not configured — hooks must never block session start.
[[ -f "$config" ]] || exit 0
# shellcheck source=/dev/null
source "$config"
[[ -n "${CHANNEL_REPO:-}" ]] || exit 0
command -v gh >/dev/null 2>&1 || exit 0

# Fetch the most recent open handoff.
latest="$(
  gh issue list \
    --repo "$CHANNEL_REPO" \
    --label "channel,type:handoff,status:open" \
    --state open \
    --limit 1 \
    --json number,title,body,url,createdAt \
    2>/dev/null || true
)"

# No handoff → no output.
[[ -n "$latest" && "$latest" != "[]" ]] || exit 0

number="$(jq -r '.[0].number' <<<"$latest")"
title="$(jq -r '.[0].title' <<<"$latest")"
url="$(jq -r '.[0].url' <<<"$latest")"
created="$(jq -r '.[0].createdAt' <<<"$latest")"
body="$(jq -r '.[0].body' <<<"$latest")"

cat <<EOF
# Channel: open handoff awaiting pickup

**$title** (#$number, opened $created)
$url

$body

---
When you finish picking this up, comment "picked up" on the issue and either close it or relabel it \`status:resolved\`. To see more channel messages: \`.channel/read.sh\`.
EOF

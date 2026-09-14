#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
VENDOR="$ROOT/vendor/sinch-skills/skills"
DEST="$ROOT/plugins/sinch-codex-plugin/skills"
PLUGIN_ROOT="$ROOT/plugins/sinch-codex-plugin"
CHECK=0

if [ "${1:-}" = "--check" ]; then
  CHECK=1
fi

PAIRS="
10dlc:sinch-10dlc
authentication:sinch-authentication
conversation-api:sinch-conversation-api
elastic-sip-trunking:sinch-elastic-sip-trunking
fax:sinch-fax-api
in-app-calling:sinch-in-app-calling
mailgun:sinch-mailgun
mailgun-inspect:sinch-mailgun-inspect
mailgun-optimize:sinch-mailgun-optimize
mailgun-validate:sinch-mailgun-validate
number-lookup:sinch-number-lookup-api
numbers:sinch-numbers-api
provisioning-api:sinch-provisioning-api
verification-api:sinch-verification-api
voice-api:sinch-voice-api
"

skill_physical_dir() {
  (CDPATH= cd -- "$1" && pwd -P)
}

failed=0
for pair in $PAIRS; do
  dest_name=${pair%%:*}
  vendor_name=${pair#*:}
  src="$VENDOR/$vendor_name"
  out="$DEST/$dest_name"

  if [ ! -d "$src" ]; then
    echo "ERROR: vendor skill missing: $src"
    failed=1
    continue
  fi

  if [ "$CHECK" -eq 1 ]; then
    if [ -L "$out" ]; then
      echo "ERROR: $out is a symlink; Codex requires a real copy inside the plugin root"
      failed=1
      continue
    fi
    if [ ! -d "$out" ] || [ ! -f "$out/SKILL.md" ]; then
      echo "ERROR: Codex skill copy missing: $out/SKILL.md"
      failed=1
      continue
    fi
    physical=$(skill_physical_dir "$out")
    case "$physical" in
      "$PLUGIN_ROOT" | "$PLUGIN_ROOT"/*) ;;
      *)
        echo "ERROR: $out resolves outside the plugin root: $physical"
        failed=1
        continue
        ;;
    esac
    if ! diff -rq "$src" "$out" >/dev/null; then
      echo "ERROR: $out is out of date with $src"
      failed=1
    fi
    continue
  fi

  rm -rf "$out"
  cp -R "$src" "$out"
done

if [ "$CHECK" -eq 1 ]; then
  if [ "$failed" -ne 0 ]; then
    echo "Codex skill copies are missing or stale. Run: scripts/sync-codex-skills.sh"
    exit 1
  fi
  echo "Codex skill copies match vendor/sinch-skills and resolve inside the plugin root"
  exit 0
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Copied product skills into $DEST"

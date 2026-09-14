#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
VENDOR="$ROOT/vendor/sinch-skills/skills"
PLUGIN_ROOT="$ROOT/plugins/sinch-codex-plugin"
DEST="$PLUGIN_ROOT/skills"
CHECK=0

if [ "${1:-}" = "--check" ]; then
  CHECK=1
fi

# Directory names match the vendor names so that cross-skill links such as
# ../sinch-authentication/SKILL.md resolve inside the plugin root.
SKILLS="
sinch-10dlc
sinch-authentication
sinch-conversation-api
sinch-elastic-sip-trunking
sinch-fax-api
sinch-in-app-calling
sinch-mailgun
sinch-mailgun-inspect
sinch-mailgun-optimize
sinch-mailgun-validate
sinch-number-lookup-api
sinch-numbers-api
sinch-provisioning-api
sinch-sdks
sinch-verification-api
sinch-voice-api
"

# Authored in this repository rather than copied from vendor.
LOCAL_SKILLS="sinch-help"

ERRORS=$(mktemp)
trap 'rm -f "$ERRORS"' EXIT

is_known_skill() {
  for known in $SKILLS $LOCAL_SKILLS; do
    if [ "$1" = "$known" ]; then
      return 0
    fi
  done
  return 1
}

if [ "$CHECK" -eq 0 ]; then
  mkdir -p "$DEST"

  for existing in "$DEST"/*; do
    [ -e "$existing" ] || [ -L "$existing" ] || continue
    name=$(basename "$existing")
    if ! is_known_skill "$name"; then
      rm -rf "$existing"
    fi
  done

  for skill in $SKILLS; do
    if [ ! -d "$VENDOR/$skill" ]; then
      echo "ERROR: vendor skill missing: $VENDOR/$skill" >> "$ERRORS"
      continue
    fi
    rm -rf "$DEST/$skill"
    cp -R "$VENDOR/$skill" "$DEST/$skill"
  done

  if [ -s "$ERRORS" ]; then
    cat "$ERRORS"
    exit 1
  fi
  echo "Copied $(echo "$SKILLS" | grep -c .) product skills into $DEST"
fi

for skill in $SKILLS; do
  out="$DEST/$skill"

  if [ -L "$out" ]; then
    echo "ERROR: $out is a symlink; Codex requires a real copy inside the plugin root" >> "$ERRORS"
    continue
  fi
  if [ ! -f "$out/SKILL.md" ]; then
    echo "ERROR: Codex skill copy missing: $out/SKILL.md" >> "$ERRORS"
    continue
  fi
  if ! diff -rq "$VENDOR/$skill" "$out" >/dev/null 2>&1; then
    echo "ERROR: $out is out of date with $VENDOR/$skill" >> "$ERRORS"
  fi

  declared=$(sed -n '1,10p' "$out/SKILL.md" | grep -m1 '^name:' | sed 's/^name:[[:space:]]*//' || true)
  if [ -n "$declared" ] && [ "$declared" != "$skill" ]; then
    echo "ERROR: $out/SKILL.md declares name '$declared' but lives in '$skill'" >> "$ERRORS"
  fi
done

# Every relative markdown link must resolve to a file inside the skills tree.
for md in $(find "$DEST" -name '*.md'); do
  dir=$(dirname "$md")
  for link in $(grep -oE '\]\([^)[:space:]]+\)' "$md" 2>/dev/null | sed 's/^](//; s/)$//' || true); do
    case "$link" in
      http://* | https://* | mailto:* | /* | \#*) continue ;;
    esac
    path=${link%%\#*}
    [ -n "$path" ] || continue
    target="$dir/$path"
    if [ ! -e "$target" ]; then
      echo "ERROR: ${md#"$ROOT"/} links to missing path: $path" >> "$ERRORS"
      continue
    fi
    physical=$(CDPATH= cd -- "$(dirname "$target")" 2>/dev/null && pwd -P) || physical=""
    case "$physical" in
      "$DEST" | "$DEST"/*) ;;
      *) echo "ERROR: ${md#"$ROOT"/} links outside the skills tree: $link" >> "$ERRORS" ;;
    esac
  done
done

if [ -s "$ERRORS" ]; then
  sort -u "$ERRORS"
  echo
  echo "Codex skills are stale or contain unresolvable links. Run: scripts/sync-codex-skills.sh"
  exit 1
fi

echo "Codex skills match vendor/sinch-skills; names and relative links resolve inside the plugin root"

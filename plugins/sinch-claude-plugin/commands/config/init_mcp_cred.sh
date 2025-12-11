#!/usr/bin/env bash
#
# Sinch Conversation API — Claude Code Settings Setup
#
set -euo pipefail

SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

echo ""
echo "========================================"
echo " Sinch Conversation API — Setup Script"
echo "========================================"
echo ""

# ----------------------------
# Step 1: Check for jq
# ----------------------------
echo "[1/7] Checking for jq..."

if ! command -v jq &> /dev/null; then
  echo "  ✗ Error: jq is required but not installed."
  echo ""
  echo "  Install it with:"
  echo "    macOS:  brew install jq"
  echo "    Ubuntu: sudo apt install jq"
  echo "    Fedora: sudo dnf install jq"
  echo ""
  exit 1
fi
echo "  ✓ jq is installed."

# ----------------------------
# Step 2: Collect credentials
# ----------------------------
echo ""
echo "[2/7] Collecting credentials..."
echo ""
echo "  Enter your Sinch Conversation API credentials."
echo "  (Input is hidden for secrets)"
echo ""

read -rp "  Sinch Project ID: " PROJECT_ID
if [[ -z "$PROJECT_ID" ]]; then
  echo "  ✗ Error: Project ID is required."
  exit 1
fi

read -rp "  Sinch API Key: " KEY_ID
if [[ -z "$KEY_ID" ]]; then
  echo "  ✗ Error: API Key is required."
  exit 1
fi

read -rsp "  Sinch API Secret: " KEY_SECRET
echo ""
if [[ -z "$KEY_SECRET" ]]; then
  echo "  ✗ Error: API Secret is required."
  exit 1
fi

read -rp "  Sinch App ID: " APP_ID
if [[ -z "$APP_ID" ]]; then
  echo "  ✗ Error: App ID is required."
  exit 1
fi

read -rp "  Region (us/eu/br) [us]: " REGION
REGION="${REGION:-us}"

# Validate region
if [[ ! "$REGION" =~ ^(us|eu|br)$ ]]; then
  echo "  ✗ Error: Region must be 'us', 'eu', or 'br'."
  exit 1
fi

echo ""
echo "  ✓ Credentials collected."

# ----------------------------
# Step 3: Ensure directory exists
# ----------------------------
echo ""
echo "[3/7] Checking settings directory..."

if [[ ! -d "$SETTINGS_DIR" ]]; then
  echo "  → Creating $SETTINGS_DIR..."
  mkdir -p "$SETTINGS_DIR"
  echo "  ✓ Directory created."
else
  echo "  ✓ Directory exists."
fi

# ----------------------------
# Step 4: Ensure settings.json exists
# ----------------------------
echo ""
echo "[4/7] Checking settings.json..."

if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo "  → Creating $SETTINGS_FILE with empty object..."
  echo '{}' > "$SETTINGS_FILE"
  echo "  ✓ File created."
else
  echo "  ✓ File exists."
  
  # Validate it's valid JSON
  if ! jq empty "$SETTINGS_FILE" 2>/dev/null; then
    echo "  ✗ Error: $SETTINGS_FILE is not valid JSON."
    echo "    Please fix the file manually or delete it to start fresh."
    exit 1
  fi
  echo "  ✓ File contains valid JSON."
fi

# ----------------------------
# Step 5: Backup existing settings
# ----------------------------
echo ""
echo "[5/7] Creating backup..."

BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SETTINGS_FILE" "$BACKUP_FILE"
echo "  ✓ Backup saved to: $BACKUP_FILE"

# ----------------------------
# Step 6: Check existing env block
# ----------------------------
echo ""
echo "[6/7] Analyzing current configuration..."

HAS_ENV=$(jq 'has("env")' "$SETTINGS_FILE")
if [[ "$HAS_ENV" == "true" ]]; then
  echo "  → Existing 'env' block found."
  
  # Check each credential
  EXISTING_KEYS=""
  for key in CONVERSATION_PROJECT_ID CONVERSATION_KEY_ID CONVERSATION_KEY_SECRET CONVERSATION_REGION CONVERSATION_APP_ID; do
    if [[ $(jq -r --arg k "$key" '.env | has($k)' "$SETTINGS_FILE") == "true" ]]; then
      EXISTING_KEYS="$EXISTING_KEYS $key"
    fi
  done
  
  if [[ -n "$EXISTING_KEYS" ]]; then
    echo "  → Will update existing values:$EXISTING_KEYS"
  else
    echo "  → No Sinch credentials found. Will add new values."
  fi
else
  echo "  → No 'env' block found. Will create one."
fi

# ----------------------------
# Step 7: Update settings.json
# ----------------------------
echo ""
echo "[7/7] Updating settings.json..."

jq --arg projectId "$PROJECT_ID" \
   --arg keyId "$KEY_ID" \
   --arg keySecret "$KEY_SECRET" \
   --arg region "$REGION" \
   --arg appId "$APP_ID" \
   '
   .env = (.env // {}) |
   .env.CONVERSATION_PROJECT_ID = $projectId |
   .env.CONVERSATION_KEY_ID = $keyId |
   .env.CONVERSATION_KEY_SECRET = $keySecret |
   .env.CONVERSATION_REGION = $region |
   .env.CONVERSATION_APP_ID = $appId
   ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"

# Validate the new file before replacing
if ! jq empty "$SETTINGS_FILE.tmp" 2>/dev/null; then
  echo "  ✗ Error: Generated invalid JSON. Aborting."
  echo "    Your original settings are unchanged."
  rm -f "$SETTINGS_FILE.tmp"
  exit 1
fi

mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
echo "  ✓ Settings updated successfully."

# ----------------------------
# Summary
# ----------------------------
echo ""
echo "========================================"
echo " Setup Complete"
echo "========================================"
echo ""
echo " Configured values:"
echo "   CONVERSATION_PROJECT_ID = $PROJECT_ID"
echo "   CONVERSATION_KEY_ID     = $KEY_ID"
echo "   CONVERSATION_KEY_SECRET = ****${KEY_SECRET: -4}"
echo "   CONVERSATION_REGION     = $REGION"
echo "   CONVERSATION_APP_ID     = $APP_ID"
echo ""
echo " Next steps:"
echo "   1. Restart Claude Code to load the new environment variables"
echo "   2. Run /sinch-claude-plugin:api:messages:send to verify the connection"
echo ""
echo " To undo, restore from backup:"
echo "   cp \"$BACKUP_FILE\" \"$SETTINGS_FILE\""
echo ""
#!/usr/bin/env bash
#
# Sinch Conversation API — Cursor credentials (env file) setup
#
# The plugin's MCP server loads credentials from ~/.sinch/mcp.env via
# Cursor's "envFile" option, so this works however Cursor is launched.
#
set -euo pipefail

ENV_DIR="$HOME/.sinch"
ENV_FILE="$ENV_DIR/mcp.env"

echo ""
echo "========================================"
echo " Sinch Conversation API — Setup Script"
echo "========================================"
echo ""

# ----------------------------
# Step 1: Collect credentials
# ----------------------------
echo "[1/4] Collecting credentials..."
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
# Step 2: Ensure directory exists
# ----------------------------
echo ""
echo "[2/4] Checking $ENV_DIR..."

if [[ ! -d "$ENV_DIR" ]]; then
  mkdir -p "$ENV_DIR"
  chmod 700 "$ENV_DIR"
  echo "  ✓ Directory created."
else
  echo "  ✓ Directory exists."
fi

# ----------------------------
# Step 3: Back up existing env file
# ----------------------------
echo ""
echo "[3/4] Checking for an existing env file..."

BACKUP_FILE=""
if [[ -f "$ENV_FILE" ]]; then
  BACKUP_FILE="$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
  cp -p "$ENV_FILE" "$BACKUP_FILE"
  echo "  ✓ Backup saved to: $BACKUP_FILE"
else
  echo "  → None found. A new one will be created."
fi

# ----------------------------
# Step 4: Write env file (owner read/write only)
# ----------------------------
echo ""
echo "[4/4] Writing $ENV_FILE..."

(
  umask 077
  cat > "$ENV_FILE.tmp" <<EOF
PROJECT_ID=$PROJECT_ID
KEY_ID=$KEY_ID
KEY_SECRET=$KEY_SECRET
CONVERSATION_REGION=$REGION
CONVERSATION_APP_ID=$APP_ID
EOF
)
mv "$ENV_FILE.tmp" "$ENV_FILE"
chmod 600 "$ENV_FILE"
echo "  ✓ Credentials saved."

# ----------------------------
# Summary
# ----------------------------
echo ""
echo "========================================"
echo " Setup Complete"
echo "========================================"
echo ""
echo " Configured values:"
echo "   PROJECT_ID = $PROJECT_ID"
echo "   KEY_ID     = $KEY_ID"
echo "   KEY_SECRET = ****${KEY_SECRET: -4}"
echo "   CONVERSATION_REGION     = $REGION"
echo "   CONVERSATION_APP_ID     = $APP_ID"
echo ""
echo " Next steps:"
echo "   1. In Cursor, restart the 'sinch' server in Settings → MCP (or reload the window)"
echo "   2. Run /sinch-cursor-plugin:api:messages:send to verify the connection"
echo ""
if [[ -n "$BACKUP_FILE" ]]; then
  echo " To undo, restore from backup:"
  echo "   cp \"$BACKUP_FILE\" \"$ENV_FILE\""
  echo ""
fi

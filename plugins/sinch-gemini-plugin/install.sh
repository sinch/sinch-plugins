#!/bin/bash

# Sinch Gemini Plugin Installation Script
# This script helps you install the Sinch custom slash commands for Gemini CLI

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_SOURCE="$PLUGIN_DIR/.gemini/commands/sinch"

echo "🚀 Sinch Gemini Plugin Installer"
echo "================================"
echo ""

# Check if Gemini CLI is installed
if ! command -v gemini &> /dev/null; then
    echo "⚠️  Gemini CLI is not installed."
    echo ""
    echo "Please install Gemini CLI first:"
    echo "  npm install -g @google/gemini-cli@latest"
    echo ""
    echo "Or use with npx:"
    echo "  npx @google/gemini-cli"
    echo ""
    exit 1
fi

echo "✅ Gemini CLI is installed"
echo ""

# Ask user for installation scope
echo "Choose installation scope:"
echo "1. User-scoped (available in all projects)"
echo "2. Project-scoped (current directory only)"
echo ""
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        INSTALL_DIR="$HOME/.gemini/commands"
        SCOPE="user-scoped"
        ;;
    2)
        INSTALL_DIR=".gemini/commands"
        SCOPE="project-scoped"
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Installing to: $INSTALL_DIR"
echo "Scope: $SCOPE"
echo ""

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy commands
if [ -d "$INSTALL_DIR/sinch" ]; then
    read -p "⚠️  sinch commands already exist. Overwrite? (y/n): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    rm -rf "$INSTALL_DIR/sinch"
fi

cp -r "$COMMANDS_SOURCE" "$INSTALL_DIR/"

echo "✅ Commands installed successfully!"
echo ""
echo "Available commands:"
echo "  /sinch:api:messages:send       - Send SMS/RCS messages"
echo "  /sinch:api:messages:status     - Get message delivery status"
echo "  /sinch:api:webhooks:list       - List webhooks"
echo "  /sinch:api:webhooks:create     - Create webhook"
echo "  /sinch:api:webhooks:update     - Update webhook"
echo "  /sinch:api:webhooks:delete     - Delete webhook"
echo "  /sinch:api:webhooks:triggers   - List available triggers"
echo "  /sinch:api:senders:list        - List/generate code for active senders"
echo ""
echo "⚙️  Configuration Required"
echo "========================="
echo "Set these environment variables in your shell profile:"
echo ""
echo "  export CONVERSATION_PROJECT_ID=\"your-project-id\""
echo "  export CONVERSATION_KEY_ID=\"your-key-id\""
echo "  export CONVERSATION_KEY_SECRET=\"your-key-secret\""
echo "  export CONVERSATION_REGION=\"us\"  # or eu, br"
echo "  export CONVERSATION_APP_ID=\"your-app-id\""
echo ""
echo "Optional (for message status):"
echo "  export NGROK_AUTH_TOKEN=\"your-ngrok-token\""
echo ""
echo "Get credentials from: https://dashboard.sinch.com/"
echo ""
echo "🎉 Installation complete! Restart your terminal or Gemini CLI session."

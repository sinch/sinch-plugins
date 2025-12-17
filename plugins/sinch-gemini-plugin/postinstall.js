#!/usr/bin/env node

/**
 * Post-install script for @sinch/gemini-plugin
 * Automatically installs commands to user's .gemini directory
 */

const fs = require("fs");
const path = require("path");
const os = require("os");

const PLUGIN_NAME = "sinch";
const HOME_DIR = os.homedir();
const GEMINI_DIR = path.join(HOME_DIR, ".gemini", "commands");
const SOURCE_DIR = path.join(__dirname, ".gemini", "commands", PLUGIN_NAME);
const TARGET_DIR = path.join(GEMINI_DIR, PLUGIN_NAME);

function copyRecursive(src, dest) {
  const stat = fs.statSync(src);

  if (stat.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }

    const files = fs.readdirSync(src);
    for (const file of files) {
      copyRecursive(path.join(src, file), path.join(dest, file));
    }
  } else {
    fs.copyFileSync(src, dest);
  }
}

function installPlugin() {
  console.log("📦 Installing Sinch Gemini Plugin...\n");

  try {
    // Create .gemini/commands directory if it doesn't exist
    if (!fs.existsSync(GEMINI_DIR)) {
      fs.mkdirSync(GEMINI_DIR, { recursive: true });
      console.log("✅ Created .gemini/commands directory");
    }

    // Check if plugin already exists
    if (fs.existsSync(TARGET_DIR)) {
      console.log("⚠️  Sinch commands already exist. Updating...");
      fs.rmSync(TARGET_DIR, { recursive: true, force: true });
    }

    // Copy commands
    copyRecursive(SOURCE_DIR, TARGET_DIR);
    console.log("✅ Commands installed successfully!\n");

    // Display available commands
    console.log("Available commands:");
    console.log("  /sinch:api:messages:send       - Send SMS/RCS messages");
    console.log(
      "  /sinch:api:messages:status     - Get message delivery status"
    );
    console.log("  /sinch:api:webhooks:list       - List webhooks");
    console.log("  /sinch:api:webhooks:create     - Create webhook");
    console.log("  /sinch:api:webhooks:update     - Update webhook");
    console.log("  /sinch:api:webhooks:delete     - Delete webhook");
    console.log("  /sinch:api:webhooks:triggers   - List available triggers");
    console.log(
      "  /sinch:api:senders:list        - List/generate code for active senders\n"
    );

    console.log("⚙️  Configuration Required");
    console.log("=========================");
    console.log("Set these environment variables in your shell profile:\n");
    console.log('  export CONVERSATION_PROJECT_ID="your-project-id"');
    console.log('  export CONVERSATION_KEY_ID="your-key-id"');
    console.log('  export CONVERSATION_KEY_SECRET="your-key-secret"');
    console.log('  export CONVERSATION_REGION="us"  # or eu, br');
    console.log('  export CONVERSATION_APP_ID="your-app-id"\n');
    console.log("Get credentials from: https://dashboard.sinch.com/\n");
    console.log(
      "🎉 Installation complete! Commands are now available in Gemini CLI."
    );
  } catch (error) {
    console.error("❌ Installation failed:", error.message);
    process.exit(1);
  }
}

// Run installation
installPlugin();

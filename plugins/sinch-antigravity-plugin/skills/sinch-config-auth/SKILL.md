---
name: sinch-config-auth
description: Show Sinch API authentication setup guide for all products
---

# Sinch Authentication Setup

Display a concise authentication guide for Sinch APIs used by this plugin. Do NOT generate script files. Output the guide directly.

## Instructions

**Display the following information directly - do not write code or scripts:**

1. **Sinch Dashboard**
   - Go to https://dashboard.sinch.com
   - Settings > Access Keys: note **Project ID**, create **Access Key** (Key ID + Key Secret). Store Key Secret securely — shown only once.

2. **Credential types by product**
   - **OAuth2 (Project ID + Key ID + Key Secret)**: Conversation API, Numbers, Fax, Batch, Templates, Number Lookup, 10DLC, Elastic SIP Trunking, Provisioning. Set: CONVERSATION_PROJECT_ID, CONVERSATION_KEY_ID, CONVERSATION_KEY_SECRET, CONVERSATION_REGION, CONVERSATION_APP_ID (for messaging).
   - **Application Key + Secret**: Voice API, Verification API. Set: VOICE_APPLICATION_KEY, VOICE_APPLICATION_SECRET; or verification app credentials.
   - **Mailgun**: MAILGUN_API_KEY, MAILGUN_DOMAIN, MAILGUN_REGION (us or eu).
   - **Mailjet**: MJ_APIKEY_PUBLIC, MJ_APIKEY_PRIVATE.

3. **Getting an OAuth2 token (for REST)**
   - POST https://auth.sinch.com/oauth2/token with grant_type=client_credentials, Basic Auth KEY_ID:KEY_SECRET. Use returned access_token as Bearer (valid ~1 hour).

4. **Plugin credentials (Antigravity)**
   - Antigravity plugins do not prompt for credentials at install time. Export environment variables in your shell before starting `agy`:
     ```bash
     export CONVERSATION_PROJECT_ID="your-project-id"
     export CONVERSATION_KEY_ID="your-key-id"
     export CONVERSATION_KEY_SECRET="your-key-secret"
     export CONVERSATION_REGION="us"   # us | eu | br
     export CONVERSATION_APP_ID="your-app-id"
     ```
   - Optional product credentials: VOICE_APPLICATION_KEY, VOICE_APPLICATION_SECRET; VERIFICATION_APPLICATION_KEY, VERIFICATION_APPLICATION_SECRET; MAILGUN_API_KEY, MAILGUN_DOMAIN, MAILGUN_REGION; MJ_APIKEY_PUBLIC, MJ_APIKEY_PRIVATE.
   - The bundled mcp_config.json passes ${CONVERSATION_*} through to the Build MCP. Restart `agy` after changing env vars.

5. **Links**
   - Dashboard: https://dashboard.sinch.com
   - Developer docs: https://developers.sinch.com
   - LLMs index: https://developers.sinch.com/llms.txt

Do not execute API calls in this command; only display the guide.

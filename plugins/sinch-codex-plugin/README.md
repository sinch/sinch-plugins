# Sinch - Codex Plugin

A Codex plugin that packages the Sinch Build skills catalog with the hosted Sinch Build Docs MCP. Use it to search official Sinch documentation and follow product guides for Conversation API, Voice, Verification, Numbers, 10DLC, Fax, Mailgun, and more.

## Overview

This plugin is read-only. Codex can retrieve authoritative Sinch developer documentation and apply the bundled product skills. It does not send messages, create webhooks, or call live Sinch APIs on your behalf.

## What's included

- **Sinch Build Docs MCP** (`sinch-docs`) at `https://developers.sinch.com/mcp` for documentation search. No credentials required.
- **16 product skills** from the Sinch Build catalog (Conversation API, Voice, Verification, Numbers, Number Lookup, 10DLC, Elastic SIP Trunking, Fax, In-app calling, Mailgun, Provisioning, SDKs, Authentication).
- **`sinch-help`** for an overview of the bundled guides.

## Prerequisites

- [Codex](https://developers.openai.com/codex) CLI or Codex in the ChatGPT desktop app.
- No Sinch account or API credentials are required to install or use this plugin.

## Installation

### From GitHub (recommended)

```bash
codex plugin marketplace add sinch/sinch-plugins
```

Then install `sinch-codex-plugin` from the Sinch marketplace in Codex.

### From a local checkout

From the repository root (the marketplace file lives at `.agents/plugins/marketplace.json`):

```bash
codex plugin marketplace add .
```

You can also point Codex at the marketplace root explicitly:

```bash
codex plugin marketplace add ./local-marketplace-root
```

Restart Codex after adding the marketplace so the plugin appears.

## MCP servers

This plugin ships only the Sinch Docs MCP. It does **not** include the credentialed Sinch Build MCP used by the other IDE plugins.

| Server | Key | Transport | Purpose |
|--------|-----|-----------|---------|
| **Sinch Docs MCP** | `sinch-docs` | remote HTTP (`https://developers.sinch.com/mcp`) | Search and read Sinch developer documentation. No credentials. |

Config field names differ by Codex package format:

- Portable `mcp.json` uses `"type": "streamable-http"` and `"url"`.
- Compatibility fallback `.mcp.json` (referenced from `.codex-plugin/plugin.json`) uses `"type": "http"` and `"url"`.

## Configuration

No credentials or environment variables are required. After install, the Docs MCP is available without further setup.

Live Sinch API calls from inside Codex (send messages, manage webhooks, and similar write actions) are not part of this plugin. That work is deferred until a remote OAuth-authenticated Build MCP exists.

## Usage

Once installed, ask Codex in natural language or invoke a product skill.

Examples:

```
Use Sinch Build to show me how to send an RCS message with SMS fallback.
Use Sinch Build to explain what I need to register a 10DLC brand and campaign.
Use Sinch Build to look up how Verification API flashcall verification works.
```

Ask Codex for `/sinch-help` (or invoke the `sinch-help` skill) for the full list of product guides.

## Skills

### Messaging and communication

- **sinch-conversation-api** - Omnichannel messaging across SMS, WhatsApp, RCS, MMS, Viber, and Messenger
- **sinch-sms** - SMS channel: sender IDs, encoding, and opt-out handling
- **sinch-mms** - MMS channel: media types, size limits, and transcoding
- **sinch-rcs** - RCS channel: rich cards, carousels, and suggested replies
- **sinch-whatsapp** - WhatsApp channel: templates and the 24-hour service window
- **sinch-in-app-calling** - In-app voice and video SDK for Android, iOS, and JavaScript
- **sinch-voice-api** - Calls, text-to-speech, IVR menus, DTMF input, and conferencing
- **sinch-voice-api-v2** - Voice API v2 (public preview) calls, webhooks, and SVAML v2
- **sinch-verification-api** - SMS, flashcall, phone call, data, and WhatsApp verification
- **sinch-fax-api** - Send and receive faxes programmatically

### Phone numbers and provisioning

- **sinch-numbers-api** - Search, rent, manage, and release numbers
- **sinch-number-order-api** - Number ordering with KYC compliance
- **sinch-porting-api** - Port numbers from other carriers into Sinch
- **sinch-imported-numbers-hosting-orders** - Import and text-enable non-Sinch numbers for SMS
- **sinch-number-lookup-api** - Carrier, line type, porting status, and SIM swap checks
- **sinch-10dlc** - US 10DLC brand and campaign registration
- **sinch-elastic-sip-trunking** - SIP trunks, endpoints, ACLs, and credential lists
- **sinch-provisioning-api** - WhatsApp and RCS sender provisioning

### Email

- **sinch-mailgun** - Send, receive, and track email
- **sinch-mailgun-validate** - Email verification and list hygiene
- **sinch-mailgun-inspect** - Pre-send email quality and accessibility checks
- **sinch-mailgun-optimize** - Inbox placement and deliverability monitoring

### Serverless and CLI

- **sinch-functions** - Sinch Functions serverless platform (beta)
- **sinch-functions-node** - Write Sinch Functions in Node.js/TypeScript
- **sinch-functions-dotnet** - Write Sinch Functions in C#/.NET
- **sinch-cli** - Sinch CLI commands

### SDKs, authentication, and help

- **sinch-sdks** - SDK installation and client initialization for Node.js, Python, Java, and .NET
- **sinch-authentication** - OAuth2, Basic auth, application signing, and API keys
- **sinch-help** - Overview of the product guides and documentation search

## Plugin structure

```
sinch-codex-plugin/
├── plugin.json                 # Portable Agent Plugins 1.0.0 manifest
├── mcp.json                    # Docs MCP (streamable-http)
├── .codex-plugin/plugin.json   # Compatibility fallback manifest
├── .mcp.json                   # Docs MCP (type http) for the fallback
├── README.md
└── skills/
    ├── sinch-help/SKILL.md
    └── sinch-conversation-api/  # 16 product skill copies from vendor/sinch-skills
```

Codex skips any `SKILL.md` that resolves outside the plugin root, so these product skills are real copies rather than symlinks. Their directory names match the vendor names so that cross-skill links such as `../sinch-authentication/SKILL.md` resolve inside the plugin.

After updating `vendor/sinch-skills`, run `scripts/sync-codex-skills.sh`. Use `scripts/sync-codex-skills.sh --check` to verify the copies are current and that every relative link resolves.

## Troubleshooting

### Plugin does not appear after marketplace add

- Confirm you added the marketplace from the repository root so Codex can find `.agents/plugins/marketplace.json`.
- Restart Codex after adding the marketplace.
- Run `codex plugin marketplace list` and look for the `sinch` marketplace.

### Docs MCP is not connected

- Confirm the plugin is enabled for the current project.
- Open MCP settings and check that `sinch-docs` points at `https://developers.sinch.com/mcp`.
- The Docs MCP needs no credentials; if a tool call fails, retry after a restart.

### Looking for send-message or webhook commands

Those actions require the credentialed Sinch Build MCP, which this plugin does not ship. Use the product skills and Docs MCP to learn how to implement them, then call the APIs from your own application or from a sibling plugin (Claude, Cursor, Gemini, or Antigravity) that includes the Build MCP.

## Links

- [Sinch Developer Hub](https://developers.sinch.com/?utm_source=Codex&utm_medium=sinch_codex_plugin)
- [Sinch Conversation API](https://developers.sinch.com/docs/conversation/?utm_source=Codex&utm_medium=sinch_codex_plugin)
- [Sinch Dashboard](https://dashboard.sinch.com/?utm_source=Codex&utm_medium=sinch_codex_plugin)
- [Sinch Help Centre](https://sinch.com/help-center/?utm_source=Codex&utm_medium=sinch_codex_plugin)
- [OpenAI Codex plugins](https://developers.openai.com/codex/plugins/build)

## Use of Sinch Services

**Use of Sinch Services**

*This repository provides developers with a way to interact with Sinch APIs and services from supported developer tools or environments. Use of Sinch services requires a valid Sinch account and is subject to the applicable Sinch Terms of Service available at:* [https://sinch.com/legal/terms-and-conditions/other-sinch-terms-conditions/terms-of-service/?utm_source=Codex&utm_medium=sinch_codex_plugin](https://sinch.com/legal/terms-and-conditions/other-sinch-terms-conditions/terms-of-service/?utm_source=Codex&utm_medium=sinch_codex_plugin)

*This repository may be used in conjunction with third-party developer tools, IDEs, platforms, or environments that are not operated or controlled by Sinch. Such third-party tools or platforms are subject to their own terms and policies.*

*The plugins in this repository are provided on an "as-is" basis, and Sinch is not responsible for the operation, availability, performance, or security of any third-party tools or platforms.*

## License

Apache-2.0

Copyright Sinch AB, [https://sinch.com/?utm_source=Codex&utm_medium=sinch_codex_plugin](https://sinch.com/?utm_source=Codex&utm_medium=sinch_codex_plugin)

Licensed under the Apache License, Version 2.0. See the LICENSE file in the repository root.

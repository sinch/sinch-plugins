---
name: sinch-help
description: Show overview of all Sinch commands available in this plugin
---

# Sinch Antigravity Plugin — Command Overview

Display a concise overview of all Sinch commands available in this plugin. Do NOT generate script files. Output the overview directly.

## Instructions

**Display the following structure directly - do not write code or scripts:**

1. **Messaging (Conversation API)**
   - /sinch-api-messages-send — Send text (SMS/RCS)
   - /sinch-api-messages-send-media — Send media (image, video, document)
   - /sinch-api-messages-send-card — Send RCS rich card
   - /sinch-api-messages-send-carousel — Send RCS carousel
   - /sinch-api-messages-send-choice — Send choice/buttons
   - /sinch-api-messages-send-location — Send location
   - /sinch-api-messages-list — List messages
   - /sinch-api-senders-list — List active numbers (Numbers API)

2. **Webhooks**
   - /sinch-api-webhooks-create, list, update, delete, triggers

3. **Batch & Templates**
   - /sinch-api-batch-send — Send batch (up to 1000 recipients)
   - /sinch-api-batch-status — Batch job status
   - /sinch-api-templates-list, create, delete

4. **Voice & Verification**
   - /sinch-api-voice-callout — TTS outbound call
   - /sinch-api-voice-calls — Call info
   - /sinch-api-verification-start — Start phone verification (SMS/Flashcall/Call)
   - /sinch-api-verification-check — Report verification code

5. **Fax & Numbers**
   - /sinch-api-fax-send, list
   - /sinch-api-numbers-lookup — Number lookup (carrier, etc.)
   - /sinch-api-numbers-search — Search available numbers to rent

6. **Email**
   - /sinch-email-mailgun-send, validate, inspect, optimize
   - /sinch-email-mailjet-send

7. **Infrastructure & Admin**
   - /sinch-api-10dlc-brands, campaigns
   - /sinch-api-sip-trunks
   - /sinch-api-provisioning-setup — WhatsApp/RCS senders
   - /sinch-api-contacts-list

8. **Config & Help**
   - /sinch-config-auth — Authentication setup guide
   - /sinch-help — This overview

9. **Product guides**
   - /10dlc — 10DLC brands and campaigns
   - /authentication — Sinch authentication overview
   - /cli — Sinch CLI
   - /conversation-api — Conversation API guide
   - /elastic-sip-trunking — Elastic SIP Trunking
   - /fax — Fax API
   - /functions — Sinch Functions platform
   - /functions-dotnet — Sinch Functions in C#/.NET
   - /functions-node — Sinch Functions in Node.js/TypeScript
   - /imported-numbers-hosting-orders — Imported numbers and hosting orders
   - /in-app-calling — In-app calling
   - /mailgun — Mailgun overview
   - /mailgun-inspect — Mailgun HTML inspection
   - /mailgun-optimize — Mailgun deliverability optimization
   - /mailgun-validate — Mailgun email validation
   - /mms — MMS channel
   - /number-lookup — Number Lookup API
   - /number-order — Number ordering with KYC
   - /numbers — Numbers API
   - /porting — Porting API
   - /provisioning-api — Provisioning (WhatsApp/RCS senders)
   - /rcs — RCS channel
   - /sdks — Sinch SDKs
   - /sms — SMS channel
   - /verification-api — Verification API
   - /voice-api — Voice API
   - /voice-api-v2 — Voice API v2 (public preview)
   - /whatsapp — WhatsApp channel

**Tip**: Run any command with no arguments for interactive mode. Export credentials in your shell (see `/sinch-config-auth`) before starting `agy`.

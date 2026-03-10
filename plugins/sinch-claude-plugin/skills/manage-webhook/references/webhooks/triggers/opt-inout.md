# OPT_IN and OPT_OUT Triggers

## Overview

The `OPT_IN` and `OPT_OUT` triggers fire when a contact opts in or out of messaging through channel-specific mechanisms. These triggers are only supported on select channels that have native opt-in/opt-out functionality (primarily Viber Business Messages).

**Important:** These triggers are NOT fired for SMS STOP keywords or similar text-based opt-out mechanisms. SMS opt-outs are handled through `MESSAGE_INBOUND`.

## When They Fire

### OPT_IN

- Contact clicks "Follow" or "Subscribe" button in a Viber Business Messages conversation
- Contact opts in via channel-specific UI elements (channel-dependent)
- Only on channels that support native opt-in mechanisms

### OPT_OUT

- Contact clicks "Unfollow" or "Unsubscribe" button in a Viber Business Messages conversation
- Contact opts out via channel-specific UI elements (channel-dependent)
- Only on channels that support native opt-out mechanisms

### NOT Triggered By

- SMS "STOP" keywords (handled as `MESSAGE_INBOUND` text message)
- Email unsubscribe links (not part of Conversation API)
- Manual opt-out status changes via API
- WhatsApp block/unblock actions

## Callback Structure

### OPT_IN

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T14:30:00.123Z",
  "project_id": "PROJECT123",
  "opt_in_notification": {
    "contact_id": "01H3333333...",
    "channel": "VIBER",
    "identity": "46732001122",
    "status": "OPT_IN_SUCCEEDED"
  }
}
```

### OPT_OUT

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T15:45:00.456Z",
  "project_id": "PROJECT123",
  "opt_out_notification": {
    "contact_id": "01H3333333...",
    "channel": "VIBER",
    "identity": "46732001122",
    "status": "OPT_OUT_SUCCEEDED"
  }
}
```

### Key Fields

| Field        | Type   | Description                                    |
| ------------ | ------ | ---------------------------------------------- |
| `contact_id` | string | Contact who opted in/out                       |
| `channel`    | string | Channel where opt action occurred              |
| `identity`   | string | Channel-specific identity (e.g., phone number) |
| `status`     | string | `OPT_IN_SUCCEEDED` or `OPT_OUT_SUCCEEDED`      |

## Supported Channels

| Channel                 | OPT_IN Support | OPT_OUT Support | Notes                                         |
| ----------------------- | -------------- | --------------- | --------------------------------------------- |
| Viber Business Messages | ✅ Yes         | ✅ Yes          | Native UI buttons                             |
| WhatsApp                | ❌ No          | ❌ No           | Use MESSAGE_INBOUND for text-based opt-in/out |
| SMS                     | ❌ No          | ❌ No           | Handle "STOP" via MESSAGE_INBOUND             |
| RCS                     | ❌ No          | ❌ No           | No native opt-in/out mechanism                |
| MMS                     | ❌ No          | ❌ No           | Handle via MESSAGE_INBOUND                    |
| Messenger               | ❌ No          | ❌ No           | Platform-managed subscriptions                |

**Note:** Channel support may expand in the future. Check Sinch documentation for current channel support.

## Common Use Cases

1. **Compliance Management** — Update subscription status when contacts opt in/out via channel UI
2. **CRM Synchronization** — Sync opt-in/opt-out status with external CRM or marketing platforms
3. **Suppression Lists** — Add opted-out contacts to suppression lists to prevent future messaging
4. **Permission Tracking** — Maintain audit trail of consent changes for GDPR/TCPA compliance
5. **Re-engagement Prevention** — Prevent sending marketing messages to opted-out contacts
6. **Channel Preference Updates** — Update contact's preferred communication channels based on opt status

## Example Callback Payloads

### Viber Business Messages Opt-In

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T14:30:00.123Z",
  "event_time": "2024-06-15T14:29:59.890Z",
  "project_id": "PROJECT123",
  "opt_in_notification": {
    "contact_id": "01H3333333...",
    "channel": "VIBER",
    "identity": "46732001122",
    "status": "OPT_IN_SUCCEEDED"
  }
}
```

### Viber Business Messages Opt-Out

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T16:00:00.456Z",
  "event_time": "2024-06-15T15:59:59.123Z",
  "project_id": "PROJECT123",
  "opt_out_notification": {
    "contact_id": "01H3333333...",
    "channel": "VIBER",
    "identity": "46732001122",
    "status": "OPT_OUT_SUCCEEDED"
  }
}
```

## Handling SMS Opt-Outs (Not Via These Triggers)

For SMS, opt-outs are handled through `MESSAGE_INBOUND` when a contact replies with keywords like "STOP", "UNSUBSCRIBE", "END", etc.

### Example SMS Opt-Out Detection

```javascript
// Handle via MESSAGE_INBOUND webhook
app.post("/webhook", (req, res) => {
  if (req.body.message && req.body.message.direction === "TO_APP") {
    const message = req.body.message;
    const text = message.contact_message?.text_message?.text?.toUpperCase();

    // Check for opt-out keywords
    if (
      text &&
      ["STOP", "UNSUBSCRIBE", "END", "CANCEL", "QUIT"].includes(text)
    ) {
      // Handle SMS opt-out
      handleOptOut(message.contact_id, "SMS");

      // Send confirmation (required by TCPA)
      sendConfirmation(
        message.contact_id,
        "You have been unsubscribed. Reply START to re-subscribe.",
      );
    }
  }

  res.sendStatus(200);
});
```

## Example Implementation

### Opt-In/Out Handler

```javascript
const optInOutHandler = async (notification, notificationType) => {
  const { contact_id, channel, identity, status } = notification;

  // Update contact subscription status in database
  await db.contacts.update({
    id: contact_id,
    [`${channel.toLowerCase()}_opted_in`]: notificationType === "OPT_IN",
  });

  // Update CRM
  await crm.updateContactPreferences({
    contactId: contact_id,
    channel: channel,
    optedIn: notificationType === "OPT_IN",
    timestamp: new Date(),
  });

  // Add to suppression list if opted out
  if (notificationType === "OPT_OUT") {
    await suppressionList.add({
      channel: channel,
      identity: identity,
      reason: "USER_INITIATED_OPT_OUT",
    });
  } else {
    await suppressionList.remove({
      channel: channel,
      identity: identity,
    });
  }

  console.log(`${notificationType}: Contact ${contact_id} on ${channel}`);
};

// Webhook endpoint
app.post("/webhook", (req, res) => {
  if (req.body.opt_in_notification) {
    optInOutHandler(req.body.opt_in_notification, "OPT_IN");
  } else if (req.body.opt_out_notification) {
    optInOutHandler(req.body.opt_out_notification, "OPT_OUT");
  }

  res.sendStatus(200);
});
```

## Key Points

1. **Limited Channel Support** — Currently only Viber Business Messages reliably supports these triggers; most channels don't
2. **Not for SMS STOP** — SMS opt-outs (STOP keywords) are delivered as regular `MESSAGE_INBOUND` messages, not via these triggers
3. **Channel-Specific UI** — These triggers only fire for native channel UI actions (buttons, settings menus), not text-based commands
4. **Always Succeeded** — Both triggers only report `OPT_IN_SUCCEEDED` and `OPT_OUT_SUCCEEDED`; there's no failed status
5. **Compliance Requirement** — Must honor opt-out requests immediately; failing to do so violates regulations (GDPR, TCPA, etc.)
6. **Bidirectional** — Contacts can opt in and out multiple times; implement proper state management
7. **Contact Identification** — Use `contact_id` to identify who opted in/out; `identity` shows the channel-specific identifier
8. **No Automatic Enforcement** — Conversation API does not automatically prevent sending to opted-out contacts; you must implement this logic
9. **Audit Trail** — Log all opt-in/opt-out events with timestamps for compliance audits
10. **External System Sync** — Update all external systems (CRM, marketing platforms, databases) when opt status changes
11. **WhatsApp Blocks** — WhatsApp blocks/reports are handled separately and don't fire these triggers; monitor delivery reports for WhatsApp policy violations instead

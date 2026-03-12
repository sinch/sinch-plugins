# RCS Template Message - JavaScript/Node.js Examples

## Overview

RCS template messages use pre-defined omni-channel templates created via the Template Management API. Templates support variable substitution, multiple languages, and can include any message type (text, card, carousel, etc.). This enables reusable message formats across all channels with dynamic content.

Use the `curl` command below to send a quick test:

```bash
curl -X POST "https://us.conversation.api.sinch.com/v1/projects/YOUR_PROJECT_ID/messages:send" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "recipient": {
      "identified_by": {
        "channel_identities": [{"channel": "RCS", "identity": "+15551234567"}]
      }
    },
    "message": {
      "template_message": {
        "template_id": "01F8MECHZX3TBDSZ7XRADM79XE",
        "parameters": {
          "customer_name": "Jane Doe",
          "order_number": "ORD-12345"
        }
      }
    }
  }'
```

## Send RCS Template Message — Using Sinch Node.js SDK

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID,
    recipient: {
      identified_by: {
        channel_identities: [
          {
            channel: "RCS",
            identity: "+15551234567",
          },
        ],
      },
    },
    message: {
      template_message: {
        template_id: "01F8MECHZX3TBDSZ7XRADM79XE",
        parameters: {
          customer_name: "Jane Doe",
          order_number: "ORD-12345",
          delivery_date: "March 20",
        },
      },
    },
  },
});

console.log("Template message sent:", response.message_id);
```

## Send Template with Specific Language — Using Node.js SDK

```javascript
const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID,
    recipient: {
      identified_by: {
        channel_identities: [
          { channel: "RCS", identity: "+15551234567" },
        ],
      },
    },
    message: {
      template_message: {
        template_id: "01F8MECHZX3TBDSZ7XRADM79XE",
        language_code: "es", // Use Spanish translation
        parameters: {
          customer_name: "María García",
          order_number: "ORD-12345",
          delivery_date: "20 de marzo",
        },
      },
    },
  },
});

console.log("Spanish template message sent:", response.message_id);
```

## Send Template with SMS Fallback — Using Node.js SDK

```javascript
const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID,
    channel_priority_order: ["RCS", "SMS"],
    recipient: {
      identified_by: {
        channel_identities: [
          { channel: "RCS", identity: "+15551234567" },
          { channel: "SMS", identity: "+15551234567" },
        ],
      },
    },
    message: {
      template_message: {
        template_id: "01F8MECHZX3TBDSZ7XRADM79XE",
        parameters: {
          tracking_number: "TRK-987654",
        },
      },
    },
    channel_properties: {
      SMS_SENDER: "+15559876543",
    },
  },
});

console.log("Template sent with SMS fallback:", response.message_id);
```

## Send Template to Contact ID — Using Node.js SDK

```javascript
const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID,
    recipient: {
      contact_id: "01E8N6MCB9SJD20WMH123456", // Contact already in Conversation API
    },
    message: {
      template_message: {
        template_id: "01F8MECHZX3TBDSZ7XRADM79XE",
        parameters: {
          customer_name: "John Smith",
          appointment_date: "March 15",
          appointment_time: "2:00 PM",
        },
      },
    },
  },
});

console.log("Template sent to contact:", response.message_id);
```

## Complete Example with Error Handling

```javascript
import { SinchClient } from "@sinch/sdk-core";

async function sendRcsTemplateMessage() {
  const sinch = new SinchClient({
    projectId: process.env.SINCH_PROJECT_ID,
    keyId: process.env.SINCH_KEY_ID,
    keySecret: process.env.SINCH_KEY_SECRET,
  });

  try {
    const response = await sinch.conversation.messages.send({
      sendMessageRequestBody: {
        app_id: process.env.SINCH_APP_ID,
        recipient: {
          identified_by: {
            channel_identities: [
              {
                channel: "RCS",
                identity: "+15551234567",
              },
            ],
          },
        },
        message: {
          template_message: {
            template_id: "01F8MECHZX3TBDSZ7XRADM79XE",
            language_code: "en-US",
            parameters: {
              customer_name: "Jane Doe",
              order_number: "ORD-12345",
              total_amount: "$99.99",
            },
          },
        },
      },
    });

    console.log("✅ Template message sent successfully");
    console.log("Message ID:", response.message_id);
    console.log("Accepted time:", response.accepted_time);
    return response;
  } catch (error) {
    console.error("❌ Failed to send template message:", error.message);
    if (error.statusCode) {
      console.error("Status code:", error.statusCode);
    }
    throw error;
  }
}

sendRcsTemplateMessage();
```

## Key Points

- **Template must exist**: Create templates first using the [Template Management API](../../templates.md) or Sinch Dashboard Message Composer
- **Parameters must match**: All variables defined in the template must have values in the `parameters` object
- **Language selection**: Use `language_code` to select a specific translation; defaults to the template's `default_translation`
- **Works across all channels**: The same template can be sent on RCS, SMS, WhatsApp, and other channels
- **Variable substitution**: Variables like `${customer_name}` in the template are replaced with values from `parameters`
- **Channel overrides**: Templates can have channel-specific overrides (e.g., use an approved WhatsApp template for WhatsApp delivery)

## Related Documentation

- [Template Management API Skill](../../templates.md)
- [Sinch Template Management API](https://developers.sinch.com/docs/conversation/templates)
- [Message Types - Template Messages](https://developers.sinch.com/docs/conversation/message-types#sending-omni-channel-templates)
- [Sinch Dashboard Message Composer](https://dashboard.sinch.com/convapi/message-composer)

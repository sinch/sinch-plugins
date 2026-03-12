# RCS Template Message - Python Examples

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

## Send RCS Template Message — Using Sinch Python SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
    project_id="YOUR_PROJECT_ID"
)

send_message_response = sinch_client.conversation.messages.send_message(
    app_id="YOUR_APP_ID",
    recipient={
        "identified_by": {
            "channel_identities": [
                {
                    "channel": "RCS",
                    "identity": "+15551234567"
                }
            ]
        }
    },
    message={
        "template_message": {
            "template_id": "01F8MECHZX3TBDSZ7XRADM79XE",
            "parameters": {
                "customer_name": "Jane Doe",
                "order_number": "ORD-12345",
                "delivery_date": "March 20"
            }
        }
    }
)

print(f"Message sent: {send_message_response.message_id}")
```

## Send Template with Specific Language — Using Python SDK

```python
send_message_response = sinch_client.conversation.messages.send_message(
    app_id="YOUR_APP_ID",
    recipient={
        "identified_by": {
            "channel_identities": [
                {
                    "channel": "RCS",
                    "identity": "+15551234567"
                }
            ]
        }
    },
    message={
        "template_message": {
            "template_id": "01F8MECHZX3TBDSZ7XRADM79XE",
            "language_code": "es",  # Use Spanish translation
            "parameters": {
                "customer_name": "María García",
                "order_number": "ORD-12345",
                "delivery_date": "20 de marzo"
            }
        }
    }
)

print(f"Spanish template message sent: {send_message_response.message_id}")
```

## Send Template with SMS Fallback — Using Python SDK

```python
send_message_response = sinch_client.conversation.messages.send_message(
    app_id="YOUR_APP_ID",
    channel_priority_order=["RCS", "SMS"],
    recipient={
        "identified_by": {
            "channel_identities": [
                {"channel": "RCS", "identity": "+15551234567"},
                {"channel": "SMS", "identity": "+15551234567"}
            ]
        }
    },
    message={
        "template_message": {
            "template_id": "01F8MECHZX3TBDSZ7XRADM79XE",
            "parameters": {
                "tracking_number": "TRK-987654"
            }
        }
    },
    channel_properties={
        "SMS_SENDER": "+15559876543"
    }
)

print(f"Template sent with SMS fallback: {send_message_response.message_id}")
```

## Send Template to Contact ID — Using Python SDK

```python
send_message_response = sinch_client.conversation.messages.send_message(
    app_id="YOUR_APP_ID",
    recipient={
        "contact_id": "01E8N6MCB9SJD20WMH123456"  # Contact already in Conversation API
    },
    message={
        "template_message": {
            "template_id": "01F8MECHZX3TBDSZ7XRADM79XE",
            "parameters": {
                "customer_name": "John Smith",
                "appointment_date": "March 15",
                "appointment_time": "2:00 PM"
            }
        }
    }
)

print(f"Template sent to contact: {send_message_response.message_id}")
```

## Complete Example with Error Handling

```python
import os
from sinch import SinchClient

def send_rcs_template_message():
    """Send an RCS template message with error handling."""
    try:
        sinch_client = SinchClient(
            key_id=os.getenv("SINCH_KEY_ID"),
            key_secret=os.getenv("SINCH_KEY_SECRET"),
            project_id=os.getenv("SINCH_PROJECT_ID")
        )

        send_message_response = sinch_client.conversation.messages.send_message(
            app_id=os.getenv("SINCH_APP_ID"),
            recipient={
                "identified_by": {
                    "channel_identities": [
                        {
                            "channel": "RCS",
                            "identity": "+15551234567"
                        }
                    ]
                }
            },
            message={
                "template_message": {
                    "template_id": "01F8MECHZX3TBDSZ7XRADM79XE",
                    "language_code": "en-US",
                    "parameters": {
                        "customer_name": "Jane Doe",
                        "order_number": "ORD-12345",
                        "total_amount": "$99.99"
                    }
                }
            }
        )

        print("✅ Template message sent successfully")
        print(f"Message ID: {send_message_response.message_id}")
        print(f"Accepted time: {send_message_response.accepted_time}")
        return send_message_response

    except Exception as error:
        print(f"❌ Failed to send template message: {str(error)}")
        raise

if __name__ == "__main__":
    send_rcs_template_message()
```

## Using Raw HTTP Requests with Python

```python
import os
import requests

def send_template_with_http():
    """Send template message using raw HTTP requests."""
    
    # Get OAuth2 token
    auth_response = requests.post(
        'https://auth.sinch.com/oauth2/token',
        data={'grant_type': 'client_credentials'},
        auth=(os.getenv('SINCH_KEY_ID'), os.getenv('SINCH_KEY_SECRET'))
    )
    access_token = auth_response.json()['access_token']
    
    # Send template message
    response = requests.post(
        f'https://us.conversation.api.sinch.com/v1/projects/{os.getenv("SINCH_PROJECT_ID")}/messages:send',
        headers={
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        },
        json={
            'app_id': os.getenv('SINCH_APP_ID'),
            'recipient': {
                'identified_by': {
                    'channel_identities': [
                        {'channel': 'RCS', 'identity': '+15551234567'}
                    ]
                }
            },
            'message': {
                'template_message': {
                    'template_id': '01F8MECHZX3TBDSZ7XRADM79XE',
                    'parameters': {
                        'customer_name': 'Jane Doe',
                        'order_number': 'ORD-12345'
                    }
                }
            }
        }
    )
    
    if response.status_code == 200:
        print(f"✅ Message sent: {response.json()['message_id']}")
    else:
        print(f"❌ Failed: {response.status_code} - {response.text}")

send_template_with_http()
```

## Key Points

- **Template must exist**: Create templates first using the [Template Management API](../../templates.md) or Sinch Dashboard Message Composer
- **Parameters must match**: All variables defined in the template must have values in the `parameters` dict
- **Language selection**: Use `language_code` to select a specific translation; defaults to the template's `default_translation`
- **Works across all channels**: The same template can be sent on RCS, SMS, WhatsApp, and other channels
- **Variable substitution**: Variables like `${customer_name}` in the template are replaced with values from `parameters`
- **Channel overrides**: Templates can have channel-specific overrides (e.g., use an approved WhatsApp template for WhatsApp delivery)

## Related Documentation

- [Template Management API Skill](../../templates.md)
- [Sinch Template Management API](https://developers.sinch.com/docs/conversation/templates)
- [Message Types - Template Messages](https://developers.sinch.com/docs/conversation/message-types#sending-omni-channel-templates)
- [Sinch Dashboard Message Composer](https://dashboard.sinch.com/convapi/message-composer)

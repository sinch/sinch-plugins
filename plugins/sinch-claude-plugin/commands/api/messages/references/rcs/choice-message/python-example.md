# RCS Choice Message - Python Examples

## Overview

RCS choice messages combine a text prompt with interactive action buttons, allowing users to quickly respond by tapping instead of typing. Choices support multiple action types (text replies, URLs, phone calls, location sharing, calendar events) and are displayed as chips below the message.

## Send RCS Choice Message — Using Python SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    project_id="YOUR_PROJECT_ID",
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
)

response = sinch_client.conversation.messages.send(
    send_message_request_body={
        "app_id": "YOUR_APP_ID",
        "recipient": {
            "identified_by": {
                "channel_identities": [
                    {"channel": "RCS", "identity": "+15551234567"}
                ]
            }
        },
        "message": {
            "choice_message": {
                "text_message": {"text": "How can we help you today?"},
                "choices": [
                    {
                        "text_message": {"text": "Track Order"},
                        "postback_data": "track_order",
                    },
                    {
                        "text_message": {"text": "Contact Support"},
                        "postback_data": "contact_support",
                    },
                    {
                        "text_message": {"text": "Browse Products"},
                        "postback_data": "browse_products",
                    },
                ],
            }
        },
    }
)

print(f"Choice message sent: {response.message_id}")
```

## Send RCS Choice — Using Python requests (no SDK)

```python
import os
import requests

def get_token(key_id: str, key_secret: str) -> str:
    resp = requests.post(
        "https://auth.sinch.com/oauth2/token",
        auth=(key_id, key_secret),
        data={"grant_type": "client_credentials"},
    )
    resp.raise_for_status()
    return resp.json()["access_token"]

def send_rcs_choice(to: str, text: str, choices: list) -> dict:
    token = get_token(os.environ["SINCH_KEY_ID"], os.environ["SINCH_KEY_SECRET"])
    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages:send"

    formatted_choices = [
        {
            "text_message": {"text": choice},
            "postback_data": choice.lower().replace(" ", "_"),
        }
        for choice in choices
    ]

    body = {
        "app_id": os.environ["SINCH_APP_ID"],
        "recipient": {
            "identified_by": {
                "channel_identities": [{"channel": "RCS", "identity": to}]
            }
        },
        "message": {
            "choice_message": {
                "text_message": {"text": text},
                "choices": formatted_choices,
            }
        },
    }

    resp = requests.post(
        url,
        headers={"Authorization": f"Bearer {token}"},
        json=body,
    )
    resp.raise_for_status()
    return resp.json()

# Usage
result = send_rcs_choice(
    "+15551234567",
    "Choose your preferred contact method:",
    ["Call Us", "Email Us", "Live Chat"]
)
print(result)
```

## Key Points

- **Choice types:** Text, URL, Call, Location, Calendar, Request Location
- **Appearance:** Rendered as chips/buttons below the message
- **Postback data:** Sent to webhook when user taps a choice
- **URL actions:** Opens link in browser or in-app webview
- **Call actions:** Triggers phone dialer with pre-filled number
- **Location actions:** Opens map app with coordinates
- **Webview mode:** Use `RCS_WEBVIEW_MODE` property (TALL, HALF, FULL)
- **SMS fallback:** Choices degrade to numbered list in text message
- **User experience:** Easier for users than typing; faster response times

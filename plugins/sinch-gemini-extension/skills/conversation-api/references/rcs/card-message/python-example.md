# RCS Card Message - Python Examples

## Overview

RCS card messages combine rich media (images or videos) with text and interactive buttons, creating engaging visual experiences. Each card can have a title (up to 200 characters), description (up to 2000 characters), media with 4:3 aspect ratio recommended, and multiple action buttons.

## Send RCS Card — Using Python SDK

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
            "card_message": {
                "title": "Summer Sale!",
                "description": "50% off all items this weekend only.",
                "media_message": {
                    "url": "https://example.com/summer-sale.jpg"
                },
                "choices": [
                    {
                        "text_message": {"text": "Shop Now"},
                        "postback_data": "shop_summer_sale",
                    },
                    {
                        "text_message": {"text": "Learn More"},
                        "postback_data": "learn_more",
                    },
                ],
            }
        },
    }
)

print(f"Card sent: {response.message_id}")
```

## Send RCS Card — Using Python requests (no SDK)

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

def send_rcs_card(to: str, title: str, description: str, image_url: str, choices: list) -> dict:
    token = get_token(os.environ["SINCH_KEY_ID"], os.environ["SINCH_KEY_SECRET"])
    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages:send"

    choices_array = [
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
            "card_message": {
                "title": title,
                "description": description,
                "media_message": {"url": image_url},
                "choices": choices_array,
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
result = send_rcs_card(
    "+15551234567",
    "Special Offer",
    "Limited time: Buy one get one free!",
    "https://example.com/offer.jpg",
    ["Shop Now", "Learn More"]
)
print(result)
```

## Key Points

- **Title:** Max 200 characters (special chars/emojis may count as 2+)
- **Description:** Max 2000 characters
- **Media:** Images or videos; recommended aspect ratio 4:3 (960x720)
- **Choices:** Interactive buttons (text, URL, call, location actions)
- **Postback data:** Identifier sent to your webhook when user taps a button
- **Orientation:** Use `RCS_CARD_ORIENTATION` channel property for horizontal/vertical layout
- **Thumbnail alignment:** Use `RCS_CARD_THUMBNAIL_IMAGE_ALIGNMENT` for image positioning
- **SMS fallback:** Card degrades to text + media link on SMS
- **Media caching:** URLs cached for 28 days; rename file to force refresh

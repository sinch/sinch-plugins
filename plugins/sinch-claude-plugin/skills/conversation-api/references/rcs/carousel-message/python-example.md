# RCS Carousel Message - Python Examples

## Overview

RCS carousel messages present 2-10 cards in a horizontally scrollable format, ideal for product catalogs, service listings, or multi-option presentations. Each card follows the same structure as a standalone card message (title, description, media, buttons), and all cards maintain uniform height. You can also include up to 3 "outer" action buttons below the entire carousel.

## Send RCS Carousel — Using Python SDK

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
            "carousel_message": {
                "cards": [
                    {
                        "title": "Product A",
                        "description": "High-quality product. Only $29.99!",
                        "media_message": {
                            "url": "https://example.com/product-a.jpg"
                        },
                        "choices": [
                            {
                                "text_message": {"text": "Buy Now"},
                                "postback_data": "buy_product_a",
                            }
                        ],
                    },
                    {
                        "title": "Product B",
                        "description": "Premium version. Just $39.99!",
                        "media_message": {
                            "url": "https://example.com/product-b.jpg"
                        },
                        "choices": [
                            {
                                "text_message": {"text": "Buy Now"},
                                "postback_data": "buy_product_b",
                            }
                        ],
                    },
                ],
                "choices": [
                    {
                        "text_message": {"text": "View All Products"},
                        "postback_data": "view_all",
                    }
                ],
            }
        },
    }
)

print(f"Carousel sent: {response.message_id}")
```

## Send RCS Carousel — Using Python requests (no SDK)

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

def send_rcs_carousel(to: str, cards: list, outer_choices: list = None) -> dict:
    token = get_token(os.environ["SINCH_KEY_ID"], os.environ["SINCH_KEY_SECRET"])
    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages:send"

    formatted_cards = [
        {
            "title": card["title"],
            "description": card["description"],
            "media_message": {"url": card["url"]},
            "choices": [
                {
                    "text_message": {"text": choice},
                    "postback_data": choice.lower().replace(" ", "_"),
                }
                for choice in card["choices"]
            ],
        }
        for card in cards
    ]

    formatted_outer = []
    if outer_choices:
        formatted_outer = [
            {
                "text_message": {"text": choice},
                "postback_data": choice.lower().replace(" ", "_"),
            }
            for choice in outer_choices
        ]

    body = {
        "app_id": os.environ["SINCH_APP_ID"],
        "recipient": {
            "identified_by": {
                "channel_identities": [{"channel": "RCS", "identity": to}]
            }
        },
        "message": {
            "carousel_message": {
                "cards": formatted_cards,
                "choices": formatted_outer,
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
cards = [
    {
        "title": "Product A",
        "description": "Amazing features. $29.99",
        "url": "https://example.com/product-a.jpg",
        "choices": ["Buy Now"],
    },
    {
        "title": "Product B",
        "description": "Premium quality. $39.99",
        "url": "https://example.com/product-b.jpg",
        "choices": ["Buy Now"],
    },
]

result = send_rcs_carousel("+15551234567", cards, ["View All Products"])
print(result)
```

## Key Points

- **Card count:** 2-10 cards (1 card renders as standalone card message)
- **Card height:** Uniform across all cards; content may be truncated
- **Outer choices:** Max 3 choices displayed below the carousel
- **Per-card choices:** Each card can have its own action buttons
- **Media:** Same constraints as card messages (4:3 aspect ratio recommended)
- **Title/description:** Same limits as card messages (200/2000 chars)
- **SMS fallback:** Carousel degrades to multiple text blocks on SMS
- **Swipeable:** Native horizontal scrolling on RCS-enabled devices
- **Best practices:** Keep content concise to avoid truncation, test on devices

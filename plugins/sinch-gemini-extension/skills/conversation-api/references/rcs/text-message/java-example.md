# RCS Text Message - Java Examples

## Overview

RCS text messages are the foundation of RCS messaging, supporting up to 3072 UTF-8 characters with native delivery receipts. They're perfect for notifications, alerts, and conversational messaging. Use the `curl` command below to send a quick test:

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
    "message": {"text_message": {"text": "Hello from RCS!"}}
  }'
```

## Send RCS Text — Using Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.text.TextMessage;

public class SendRcsText {
    public static void main(String[] args) {
        var config = Configuration.builder()
                .setProjectId("YOUR_PROJECT_ID")
                .setKeyId("YOUR_KEY_ID")
                .setKeySecret("YOUR_KEY_SECRET")
                .build();

        var sinch = new SinchClient(config);

        var response = sinch.conversation().messages().sendMessage(
                SendMessageRequest.builder()
                        .setAppId("YOUR_APP_ID")
                        .setRecipient(/* identified_by channel_identities */)
                        .setMessage(TextMessage.builder()
                                .setText("Hello from RCS!")
                                .build())
                        .build());

        System.out.println("Message sent: " + response.getMessageId());
    }
}
```

## Key Points

- **Max length:** RCS text messages support up to 3072 characters
- **Encoding:** UTF-8 (supports all Unicode characters including emojis)
- **Delivery receipts:** Native support for delivered, read, and failed statuses
- **Typing indicators:** Can be sent separately using composing events
- **SMS fallback:** Always recommended for critical messages
- **Rich text:** Plain text only; use card/carousel messages for rich formatting

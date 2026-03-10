# RCS Card Message - Java Examples

## Overview

RCS card messages create rich, interactive experiences by combining title, description, media, and action buttons. Cards support titles up to 200 characters, descriptions up to 2000 characters, and media with a recommended 4:3 aspect ratio. Use cards for product showcases, promotions, or any content requiring visual engagement.

## Send RCS Card — Using Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.card.CardMessage;

public class SendRcsCard {
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
                        .setMessage(CardMessage.builder()
                                .setTitle("Summer Sale!")
                                .setDescription("50% off all items this weekend only.")
                                .setMediaMessage(/* media message with image URL */)
                                .setChoices(/* array of text choices */)
                                .build())
                        .build());

        System.out.println("Card sent: " + response.getMessageId());
    }
}
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

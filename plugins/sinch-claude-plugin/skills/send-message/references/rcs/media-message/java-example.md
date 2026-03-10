# RCS Media Message - Java Examples

## Overview

RCS media messages send standalone images, videos, or audio via HTTPS URLs. Videos support optional thumbnail images for better preview experience. For content requiring text or interactive buttons with media, use card or carousel messages instead.

## Send RCS Media — Using Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.media.MediaMessage;

public class SendRcsMedia {
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
                        .setMessage(MediaMessage.builder()
                                .setUrl("https://example.com/image.jpg")
                                .build())
                        .build());

        System.out.println("Media sent: " + response.getMessageId());
    }
}
```

## Key Points

- **Media types:** Images (JPG, PNG, GIF), videos (MP4), audio (MP3, AAC)
- **File size:** Max 10MB for images, 100MB for videos
- **URL requirement:** Must be HTTPS and publicly accessible
- **Thumbnail:** Optional for videos; enhances preview experience
- **Caching:** Media URLs are cached for 28 days by carriers
- **SMS fallback:** Media sent as URL link in text message
- **Use cards:** For media with text/buttons, use card or carousel messages

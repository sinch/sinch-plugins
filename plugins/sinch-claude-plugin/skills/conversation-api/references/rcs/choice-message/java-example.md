# RCS Choice Message - Java Examples

## Overview

RCS choice messages provide a text prompt with interactive buttons (chips) that users can tap for quick responses. Choices support various action types (text, URL, call, location, calendar) and appear as chips below the message, creating a more engaging and faster user experience than traditional text input.

## Send RCS Choice Message — Using Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.choice.ChoiceMessage;

public class SendRcsChoice {
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
                        .setMessage(ChoiceMessage.builder()
                                .setTextMessage(/* text message */)
                                .setChoices(/* array of choice options */)
                                .build())
                        .build());

        System.out.println("Choice message sent: " + response.getMessageId());
    }
}
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

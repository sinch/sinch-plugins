# RCS Carousel Message - Java Examples

## Overview

RCS carousel messages enable horizontal scrolling through 2-10 cards, creating an interactive gallery experience. Each card includes title, description, media, and action buttons. All cards maintain uniform height, and you can add up to 3 "outer" buttons below the entire carousel for global actions. Carousels are excellent for product showcases, service menus, or any multi-option presentation.

## Send RCS Carousel — Using Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.carousel.CarouselMessage;

public class SendRcsCarousel {
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
                        .setMessage(CarouselMessage.builder()
                                .setCards(/* array of card messages */)
                                .setChoices(/* optional outer choices */)
                                .build())
                        .build());

        System.out.println("Carousel sent: " + response.getMessageId());
    }
}
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

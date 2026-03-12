# RCS Location Message - Java Examples

## Overview

RCS location messages transmit geographic coordinates (latitude/longitude) along with a descriptive title and label. Recipients see an interactive button that launches their map app with the specified location. Perfect for store locations, meeting points, delivery zones, or ride-sharing pickups.

## Send RCS Location — Using Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.location.LocationMessage;

public class SendRcsLocation {
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
                        .setMessage(LocationMessage.builder()
                                .setTitle("Our Store Location")
                                .setLabel("Visit us at 123 Main Street, Downtown")
                                .setCoordinates(/* latitude, longitude */)
                                .build())
                        .build());

        System.out.println("Location sent: " + response.getMessageId());
    }
}
```

## Key Points

- **Title:** Short name for the location (e.g., "Our Store")
- **Label:** Additional context (e.g., "Visit us at 123 Main St")
- **Coordinates:** Latitude and longitude (decimal degrees)
- **Rendering:** RCS transcodes to text with a location choice button
- **User action:** Tapping opens map app with the coordinates
- **SMS fallback:** Sent as text with Google Maps URL
- **Use cases:** Store locations, meeting points, delivery addresses, ride-sharing pickup
- **Accuracy:** Use precise coordinates for best user experience

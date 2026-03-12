# RCS Template Message - Java Examples

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

## Send RCS Template Message — Using Sinch Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.domains.conversation.models.*;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.*;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.*;
import com.sinch.sdk.domains.conversation.models.v1.messages.response.*;

import java.util.HashMap;
import java.util.Map;

public class SendRcsTemplateMessage {
    public static void main(String[] args) {
        SinchClient sinchClient = SinchClient.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .build();

        // Define template parameters
        Map<String, String> parameters = new HashMap<>();
        parameters.put("customer_name", "Jane Doe");
        parameters.put("order_number", "ORD-12345");
        parameters.put("delivery_date", "March 20");

        SendMessageRequest request = SendMessageRequest.builder()
                .setAppId(System.getenv("SINCH_APP_ID"))
                .setRecipient(
                        ConversationRecipient.builder()
                                .setIdentifiedBy(
                                        IdentifiedBy.builder()
                                                .setChannelIdentities(
                                                        Collections.singletonList(
                                                                ChannelIdentity.builder()
                                                                        .setChannel(ConversationChannel.RCS)
                                                                        .setIdentity("+15551234567")
                                                                        .build()
                                                        )
                                                )
                                                .build()
                                )
                                .build()
                )
                .setMessage(
                        ConversationMessage.builder()
                                .setTemplateMessage(
                                        TemplateMessage.builder()
                                                .setTemplateId("01F8MECHZX3TBDSZ7XRADM79XE")
                                                .setParameters(parameters)
                                                .build()
                                )
                                .build()
                )
                .build();

        SendMessageResponse response = sinchClient.conversation().messages().send(request);
        System.out.println("Message sent: " + response.getMessageId());
    }
}
```

## Send Template with Specific Language — Using Java SDK

```java
import java.util.HashMap;
import java.util.Map;

// Define template parameters
Map<String, String> parameters = new HashMap<>();
parameters.put("customer_name", "María García");
parameters.put("order_number", "ORD-12345");
parameters.put("delivery_date", "20 de marzo");

SendMessageRequest request = SendMessageRequest.builder()
        .setAppId(System.getenv("SINCH_APP_ID"))
        .setRecipient(
                ConversationRecipient.builder()
                        .setIdentifiedBy(
                                IdentifiedBy.builder()
                                        .setChannelIdentities(
                                                Collections.singletonList(
                                                        ChannelIdentity.builder()
                                                                .setChannel(ConversationChannel.RCS)
                                                                .setIdentity("+15551234567")
                                                                .build()
                                                )
                                        )
                                        .build()
                        )
                        .build()
        )
        .setMessage(
                ConversationMessage.builder()
                        .setTemplateMessage(
                                TemplateMessage.builder()
                                        .setTemplateId("01F8MECHZX3TBDSZ7XRADM79XE")
                                        .setLanguageCode("es") // Use Spanish translation
                                        .setParameters(parameters)
                                        .build()
                        )
                        .build()
        )
        .build();

SendMessageResponse response = sinchClient.conversation().messages().send(request);
System.out.println("Spanish template message sent: " + response.getMessageId());
```

## Send Template with SMS Fallback — Using Java SDK

```java
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

// Define template parameters
Map<String, String> parameters = new HashMap<>();
parameters.put("tracking_number", "TRK-987654");

// Define channel properties for SMS fallback
Map<String, String> smsProperties = new HashMap<>();
smsProperties.put("SMS_SENDER", "+15559876543");

SendMessageRequest request = SendMessageRequest.builder()
        .setAppId(System.getenv("SINCH_APP_ID"))
        .setChannelPriorityOrder(Arrays.asList(
                ConversationChannel.RCS,
                ConversationChannel.SMS
        ))
        .setRecipient(
                ConversationRecipient.builder()
                        .setIdentifiedBy(
                                IdentifiedBy.builder()
                                        .setChannelIdentities(Arrays.asList(
                                                ChannelIdentity.builder()
                                                        .setChannel(ConversationChannel.RCS)
                                                        .setIdentity("+15551234567")
                                                        .build(),
                                                ChannelIdentity.builder()
                                                        .setChannel(ConversationChannel.SMS)
                                                        .setIdentity("+15551234567")
                                                        .build()
                                        ))
                                        .build()
                        )
                        .build()
        )
        .setMessage(
                ConversationMessage.builder()
                        .setTemplateMessage(
                                TemplateMessage.builder()
                                        .setTemplateId("01F8MECHZX3TBDSZ7XRADM79XE")
                                        .setParameters(parameters)
                                        .build()
                        )
                        .build()
        )
        .setChannelProperties(smsProperties)
        .build();

SendMessageResponse response = sinchClient.conversation().messages().send(request);
System.out.println("Template sent with SMS fallback: " + response.getMessageId());
```

## Send Template to Contact ID — Using Java SDK

```java
import java.util.HashMap;
import java.util.Map;

// Define template parameters
Map<String, String> parameters = new HashMap<>();
parameters.put("customer_name", "John Smith");
parameters.put("appointment_date", "March 15");
parameters.put("appointment_time", "2:00 PM");

SendMessageRequest request = SendMessageRequest.builder()
        .setAppId(System.getenv("SINCH_APP_ID"))
        .setRecipient(
                ConversationRecipient.builder()
                        .setContactId("01E8N6MCB9SJD20WMH123456") // Contact already in Conversation API
                        .build()
        )
        .setMessage(
                ConversationMessage.builder()
                        .setTemplateMessage(
                                TemplateMessage.builder()
                                        .setTemplateId("01F8MECHZX3TBDSZ7XRADM79XE")
                                        .setParameters(parameters)
                                        .build()
                        )
                        .build()
        )
        .build();

SendMessageResponse response = sinchClient.conversation().messages().send(request);
System.out.println("Template sent to contact: " + response.getMessageId());
```

## Complete Example with Error Handling

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.domains.conversation.models.*;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.*;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.*;
import com.sinch.sdk.domains.conversation.models.v1.messages.response.*;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class SendRcsTemplateMessageWithErrorHandling {
    public static void main(String[] args) {
        try {
            SinchClient sinchClient = SinchClient.builder()
                    .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                    .setKeyId(System.getenv("SINCH_KEY_ID"))
                    .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                    .build();

            // Define template parameters
            Map<String, String> parameters = new HashMap<>();
            parameters.put("customer_name", "Jane Doe");
            parameters.put("order_number", "ORD-12345");
            parameters.put("total_amount", "$99.99");

            SendMessageRequest request = SendMessageRequest.builder()
                    .setAppId(System.getenv("SINCH_APP_ID"))
                    .setRecipient(
                            ConversationRecipient.builder()
                                    .setIdentifiedBy(
                                            IdentifiedBy.builder()
                                                    .setChannelIdentities(
                                                            Collections.singletonList(
                                                                    ChannelIdentity.builder()
                                                                            .setChannel(ConversationChannel.RCS)
                                                                            .setIdentity("+15551234567")
                                                                            .build()
                                                            )
                                                    )
                                                    .build()
                                    )
                                    .build()
                    )
                    .setMessage(
                            ConversationMessage.builder()
                                    .setTemplateMessage(
                                            TemplateMessage.builder()
                                                    .setTemplateId("01F8MECHZX3TBDSZ7XRADM79XE")
                                                    .setLanguageCode("en-US")
                                                    .setParameters(parameters)
                                                    .build()
                                    )
                                    .build()
                    )
                    .build();

            SendMessageResponse response = sinchClient.conversation().messages().send(request);

            System.out.println("✅ Template message sent successfully");
            System.out.println("Message ID: " + response.getMessageId());
            System.out.println("Accepted time: " + response.getAcceptedTime());

        } catch (Exception e) {
            System.err.println("❌ Failed to send template message: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Maven Dependency

```xml
<dependency>
    <groupId>com.sinch.sdk</groupId>
    <artifactId>sinch-sdk-java</artifactId>
    <version>1.0.0</version>
</dependency>
```

## Key Points

- **Template must exist**: Create templates first using the [Template Management API](../../templates.md) or Sinch Dashboard Message Composer
- **Parameters must match**: All variables defined in the template must have values in the `parameters` Map
- **Language selection**: Use `setLanguageCode()` to select a specific translation; defaults to the template's `default_translation`
- **Works across all channels**: The same template can be sent on RCS, SMS, WhatsApp, and other channels
- **Variable substitution**: Variables like `${customer_name}` in the template are replaced with values from `parameters`
- **Channel overrides**: Templates can have channel-specific overrides (e.g., use an approved WhatsApp template for WhatsApp delivery)

## Related Documentation

- [Template Management API Skill](../../templates.md)
- [Sinch Template Management API](https://developers.sinch.com/docs/conversation/templates)
- [Message Types - Template Messages](https://developers.sinch.com/docs/conversation/message-types#sending-omni-channel-templates)
- [Sinch Dashboard Message Composer](https://dashboard.sinch.com/convapi/message-composer)

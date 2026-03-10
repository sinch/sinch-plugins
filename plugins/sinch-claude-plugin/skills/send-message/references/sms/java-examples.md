# Java Examples

## Send SMS — Using Sinch Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.ConversationChannel;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentities;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentity;
import com.sinch.sdk.domains.conversation.models.v1.messages.AppMessage;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.response.SendMessageResponse;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.text.TextMessage;

/**
 * Send SMS using Sinch Java SDK
 * 
 * Required environment variables:
 * - SINCH_PROJECT_ID
 * - SINCH_KEY_ID
 * - SINCH_KEY_SECRET
 * - SINCH_APP_ID
 */
public class SendSms {

    public static void main(String[] args) {
        try {
            var config = Configuration.builder()
                    .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                    .setKeyId(System.getenv("SINCH_KEY_ID"))
                    .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                    .build();

            var sinch = new SinchClient(config);

            SendMessageResponse response = sinch.conversation().v1().messages().sendMessage(
                    SendMessageRequest.<TextMessage>builder()
                            .setAppId(System.getenv("SINCH_APP_ID"))
                            .setRecipient(ChannelRecipientIdentities.of(
                                    ChannelRecipientIdentity.builder()
                                            .setChannel(ConversationChannel.SMS)
                                            .setIdentity("+1555123456")
                                            .build()))
                            .setMessage(AppMessage.<TextMessage>builder()
                                    .setBody(TextMessage.builder()
                                            .setText("Hello from Sinch SMS!")
                                            .build())
                                    .build())
                            .build());

            System.out.println("Message sent successfully!");
            System.out.println("Message ID: " + response.getMessageId());
        } catch (Exception e) {
            System.err.println("Error sending SMS: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

**Maven dependency:**

```xml
<dependency>
    <groupId>com.sinch.sdk</groupId>
    <artifactId>sinch-sdk-java</artifactId>
    <version>LATEST</version>
</dependency>
```

## Send SMS as a Function — Using Sinch Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.ConversationChannel;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentities;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentity;
import com.sinch.sdk.domains.conversation.models.v1.messages.AppMessage;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.response.SendMessageResponse;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.text.TextMessage;
import java.util.Collections;

public class SendSmsFunction {

    static SendMessageResponse sendSms(SinchClient sinch, String appId, String to, String text, String sender) {
        return sinch.conversation().v1().messages().sendMessage(
                SendMessageRequest.<TextMessage>builder()
                        .setAppId(appId)
                        .setRecipient(ChannelRecipientIdentities.of(
                                ChannelRecipientIdentity.builder()
                                        .setChannel(ConversationChannel.SMS)
                                        .setIdentity(to)
                                        .build()))
                        .setMessage(AppMessage.<TextMessage>builder()
                                .setBody(TextMessage.builder().setText(text).build())
                                .build())
                        .setChannelProperties(Collections.singletonMap("SMS_SENDER", sender))
                        .build());
    }

    public static void main(String[] args) {
        var config = Configuration.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .build();

        var sinch = new SinchClient(config);

        SendMessageResponse response = sendSms(
                sinch,
                System.getenv("SINCH_APP_ID"),
                "+15551234567",
                "Hello from Java!",
                "+15559876543");
        System.out.println("Message sent: " + response.getMessageId());
    }
}
```

## List Messages — Using Sinch Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.ConversationChannel;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.MessagesListRequest;

/**
 * List SMS messages using Sinch Java SDK
 * 
 * Required environment variables:
 * - SINCH_PROJECT_ID
 * - SINCH_KEY_ID
 * - SINCH_KEY_SECRET
 */
public class ListSms {

    public static void main(String[] args) {
        try {
            var config = Configuration.builder()
                    .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                    .setKeyId(System.getenv("SINCH_KEY_ID"))
                    .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                    .build();

            var sinch = new SinchClient(config);

            System.out.println("Fetching SMS messages...\n");

            // List messages using the conversation API
            var request = MessagesListRequest.builder()
                    .setChannel(ConversationChannel.SMS)
                    .setPageSize(20)
                    .build();
            
            var response = sinch.conversation().v1().messages().list(request);
            
            if (response == null || response.getContent() == null || response.getContent().isEmpty()) {
                System.out.println("No SMS messages found.");
            } else {
                System.out.println("Found " + response.getContent().size() + " messages:\n");
                
                response.getContent().forEach(msg -> {
                    String direction = msg.getDirection().toString();
                    String directionSymbol = direction.equals("TO_CONTACT") ? "→ Sent" : "← Received";
                    String acceptTime = msg.getAcceptTime() != null ? msg.getAcceptTime().toString() : "N/A";
                    
                    String identity = "Unknown";
                    if (msg.getChannelIdentity() != null) {
                        identity = msg.getChannelIdentity().getIdentity();
                    }
                    
                    System.out.println("[" + acceptTime + "] " + directionSymbol + " | To/From: " + identity);
                    System.out.println("  ID: " + msg.getId());
                    System.out.println();
                });
                
                System.out.println("Total messages: " + response.getContent().size());
                
                if (response.hasNextPage()) {
                    System.out.println("\nMore messages available.");
                }
            }
        } catch (Exception e) {
            System.err.println("Error listing SMS messages: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Send SMS with Fallback — Using Sinch Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.ConversationChannel;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentities;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentity;
import com.sinch.sdk.domains.conversation.models.v1.messages.AppMessage;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.response.SendMessageResponse;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.text.TextMessage;
import java.util.Arrays;

public class SendSmsWithFallback {

    public static void main(String[] args) {
        try {
            var config = Configuration.builder()
                    .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                    .setKeyId(System.getenv("SINCH_KEY_ID"))
                    .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                    .build();

            var sinch = new SinchClient(config);

            SendMessageResponse response = sinch.conversation().v1().messages().sendMessage(
                    SendMessageRequest.<TextMessage>builder()
                            .setAppId(System.getenv("SINCH_APP_ID"))
                            .setChannelPriorityOrder(Arrays.asList(
                                    ConversationChannel.WHATSAPP,
                                    ConversationChannel.SMS))
                            .setRecipient(ChannelRecipientIdentities.of(
                                    ChannelRecipientIdentity.builder()
                                            .setChannel(ConversationChannel.WHATSAPP)
                                            .setIdentity("+15551234567")
                                            .build(),
                                    ChannelRecipientIdentity.builder()
                                            .setChannel(ConversationChannel.SMS)
                                            .setIdentity("+15551234567")
                                            .build()))
                            .setMessage(AppMessage.<TextMessage>builder()
                                    .setBody(TextMessage.builder()
                                            .setText("Your order has shipped!")
                                            .build())
                                    .build())
                            .build());

            System.out.println("Message sent: " + response.getMessageId());
        } catch (Exception e) {
            System.err.println("Error sending SMS: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Send Template Message — Using Sinch Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.ConversationChannel;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentities;
import com.sinch.sdk.domains.conversation.models.v1.ChannelRecipientIdentity;
import com.sinch.sdk.domains.conversation.models.v1.messages.AppMessage;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.SendMessageRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.response.SendMessageResponse;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.template.TemplateMessage;
import com.sinch.sdk.domains.conversation.models.v1.messages.types.template.OmniTemplate;

public class SendTemplateMessage {

    public static void main(String[] args) {
        try {
            var config = Configuration.builder()
                    .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                    .setKeyId(System.getenv("SINCH_KEY_ID"))
                    .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                    .build();

            var sinch = new SinchClient(config);

            SendMessageResponse response = sinch.conversation().v1().messages().sendMessage(
                    SendMessageRequest.<TemplateMessage>builder()
                            .setAppId(System.getenv("SINCH_APP_ID"))
                            .setRecipient(ChannelRecipientIdentities.of(
                                    ChannelRecipientIdentity.builder()
                                            .setChannel(ConversationChannel.SMS)
                                            .setIdentity("+15551234567")
                                            .build()))
                            .setMessage(AppMessage.<TemplateMessage>builder()
                                    .setBody(TemplateMessage.builder()
                                            .setOmniTemplate(OmniTemplate.builder()
                                                    .setTemplateId("YOUR_TEMPLATE_ID")
                                                    .setVersion("1")
                                                    .build())
                                            .build())
                                    .build())
                            .build());

            System.out.println("Message sent: " + response.getMessageId());
        } catch (Exception e) {
            System.err.println("Error sending template message: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

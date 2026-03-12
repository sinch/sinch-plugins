# Update Webhook - Java Example

## Using sinch-sdk-java

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.domains.conversation.api.v1.WebhooksService;
import com.sinch.sdk.domains.conversation.models.v1.webhooks.*;
import com.sinch.sdk.models.ConversationRegion;
import java.util.Arrays;

public class UpdateWebhookExample {
    public static void main(String[] args) {
        SinchClient sinchClient = SinchClient.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .setConversationRegion(ConversationRegion.US)  // or EU, BR
                .build();

        try {
            WebhooksService webhooksService = sinchClient.conversation().v1().webhooks();

            // Build webhook update
            Webhook webhookUpdate = Webhook.builder()
                    .setTarget("https://your-new-server.com/webhook")
                    .setTriggers(Arrays.asList(
                            WebhookTrigger.MESSAGE_INBOUND,
                            WebhookTrigger.MESSAGE_DELIVERY,
                            WebhookTrigger.EVENT_INBOUND,
                            WebhookTrigger.CONVERSATION_START
                    ))
                    .setSecret("new-webhook-secret")
                    .build();

            // Update the webhook with field mask
            Webhook updatedWebhook = webhooksService.update(
                    "YOUR_WEBHOOK_ID",
                    webhookUpdate,
                    Arrays.asList("target", "triggers", "secret")  // Specify which fields to update
            );

            System.out.println("Webhook updated: " + updatedWebhook);
            System.out.println("New target: " + updatedWebhook.getTarget());

        } catch (Exception e) {
            System.err.println("Failed to update webhook: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Raw HTTP with OAuth2.0

```java
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublishers;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import org.json.JSONObject;

public class UpdateWebhookRawOAuth {
    private static final HttpClient client = HttpClient.newHttpClient();

    // Step 1: Get access token
    public static String getAccessToken(String keyId, String keySecret) throws Exception {
        String auth = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes());

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://auth.sinch.com/oauth2/token"))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(BodyPublishers.ofString("grant_type=client_credentials"))
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Auth failed: " + response.statusCode() + " " + response.body());
        }

        return new JSONObject(response.body()).getString("access_token");
    }

    // Step 2: Update webhook
    public static JSONObject updateWebhook(String projectId, String webhookId,
            String accessToken, JSONObject updateData, List<String> updateMask) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String maskParam = String.join(",", updateMask);
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/webhooks/%s?update_mask=%s",
                region, projectId, webhookId,
                URLEncoder.encode(maskParam, StandardCharsets.UTF_8));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + accessToken)
                .header("Content-Type", "application/json")
                .method("PATCH", BodyPublishers.ofString(updateData.toString()))
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Update webhook failed: " + response.statusCode() +
                    " " + response.body());
        }

        return new JSONObject(response.body());
    }

    // Usage
    public static void main(String[] args) {
        try {
            String token = getAccessToken(
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET")
            );

            JSONObject updateData = new JSONObject()
                    .put("target", "https://your-new-server.com/webhook")
                    .put("triggers", new String[]{"MESSAGE_INBOUND", "MESSAGE_DELIVERY"});

            JSONObject webhook = updateWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_WEBHOOK_ID",
                    token,
                    updateData,
                    List.of("target", "triggers")
            );

            System.out.println("Webhook updated: " + webhook.toString(2));

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Raw HTTP with Basic Auth (Testing Only)

```java
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublishers;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import org.json.JSONObject;

public class UpdateWebhookRawBasic {
    private static final HttpClient client = HttpClient.newHttpClient();

    public static JSONObject updateWebhook(String projectId, String webhookId,
            String keyId, String keySecret, JSONObject updateData, List<String> updateMask) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String maskParam = String.join(",", updateMask);
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/webhooks/%s?update_mask=%s",
                region, projectId, webhookId,
                URLEncoder.encode(maskParam, StandardCharsets.UTF_8));

        String auth = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes());

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/json")
                .method("PATCH", BodyPublishers.ofString(updateData.toString()))
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Failed: " + response.statusCode() + " " + response.body());
        }

        return new JSONObject(response.body());
    }

    // Usage
    public static void main(String[] args) {
        try {
            JSONObject updateData = new JSONObject()
                    .put("target", "https://your-new-server.com/webhook")
                    .put("triggers", new String[]{"MESSAGE_INBOUND", "MESSAGE_DELIVERY"});

            JSONObject webhook = updateWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_WEBHOOK_ID",
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET"),
                    updateData,
                    List.of("target", "triggers")
            );

            System.out.println("Webhook updated: " + webhook.toString(2));

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Key Points

1. **update_mask required** — must specify which fields to update (e.g., `target`, `triggers`, `secret`)
2. **Partial updates** — only fields in update_mask are modified, others remain unchanged
3. **Webhook ID required** — use the ID returned from create or list operations
4. **Regional endpoint** — use `ConversationRegion.US`, `.EU`, or `.BR` matching your app
5. **Cannot change app_id** — webhooks are permanently bound to their original app
6. **Triggers replacement** — triggers list replaces existing triggers completely
7. **Immediate effect** — updated configuration takes effect immediately
8. **Exception handling** — catch API exceptions for 404 if webhook not found, 400 for invalid update_mask or data
9. **OAuth2.0 update** — can update ClientCredentials to change OAuth2.0 config
10. **Returns complete webhook** — response includes all fields with updated values

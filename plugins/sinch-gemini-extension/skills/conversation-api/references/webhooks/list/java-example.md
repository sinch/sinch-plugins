# List Webhooks - Java Example

## Using sinch-sdk-java

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.domains.conversation.api.v1.WebhooksService;
import com.sinch.sdk.domains.conversation.models.v1.webhooks.*;
import com.sinch.sdk.models.ConversationRegion;
import java.util.Collection;

public class ListWebhooksExample {
    public static void main(String[] args) {
        SinchClient sinchClient = SinchClient.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .setConversationRegion(ConversationRegion.US)  // or EU, BR
                .build();

        try {
            WebhooksService webhooksService = sinchClient.conversation().v1().webhooks();

            // List webhooks for an app
            Collection<Webhook> webhooks = webhooksService.list("YOUR_APP_ID");

            System.out.println("Webhooks: " + webhooks);
            System.out.println("Found " + webhooks.size() + " webhooks");

            for (Webhook webhook : webhooks) {
                System.out.println("- " + webhook.getId() + ": " + webhook.getTarget());
                System.out.println("  Triggers: " + webhook.getTriggers());
            }

        } catch (Exception e) {
            System.err.println("Failed to list webhooks: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Raw HTTP with OAuth2.0

```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublishers;
import java.util.Base64;
import org.json.JSONObject;
import org.json.JSONArray;

public class ListWebhooksRawOAuth {
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

    // Step 2: List webhooks
    public static JSONArray listWebhooks(String projectId, String appId,
            String accessToken) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/apps/%s/webhooks",
                region, projectId, appId);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + accessToken)
                .header("Content-Type", "application/json")
                .GET()
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("List webhooks failed: " + response.statusCode() +
                    " " + response.body());
        }

        return new JSONArray(response.body());
    }

    // Usage
    public static void main(String[] args) {
        try {
            String token = getAccessToken(
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET")
            );

            JSONArray webhooks = listWebhooks(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_APP_ID",
                    token
            );

            System.out.println("Webhooks: " + webhooks.toString(2));

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
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Base64;
import org.json.JSONArray;

public class ListWebhooksRawBasic {
    private static final HttpClient client = HttpClient.newHttpClient();

    public static JSONArray listWebhooks(String projectId, String appId,
            String keyId, String keySecret) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/apps/%s/webhooks",
                region, projectId, appId);

        String auth = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes());

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/json")
                .GET()
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Failed: " + response.statusCode() + " " + response.body());
        }

        return new JSONArray(response.body());
    }

    // Usage
    public static void main(String[] args) {
        try {
            JSONArray webhooks = listWebhooks(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_APP_ID",
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET")
            );

            System.out.println("Webhooks: " + webhooks.toString(2));

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Key Points

1. **App scoped** — list returns only webhooks for specified app_id
2. **Maximum 5 webhooks per app** — list will return at most 5 webhooks
3. **No pagination** — all webhooks returned in single response
4. **Regional endpoint** — use `ConversationRegion.US`, `.EU`, or `.BR` matching your app
5. **Returns Collection** — empty collection if no webhooks configured
6. **Full webhook objects** — includes id, target, triggers, secret (masked), client_credentials
7. **Exception handling** — catch API exceptions for 404 if app not found, 403 for permission errors
8. **Lightweight operation** — safe to call frequently for monitoring
9. **Use for validation** — check existing webhooks before creating new ones
10. **Active webhooks only** — does not include deleted webhooks

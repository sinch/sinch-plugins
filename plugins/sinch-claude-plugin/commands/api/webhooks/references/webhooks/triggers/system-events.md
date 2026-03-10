# System Events Triggers

## Overview

System event triggers deliver notifications about channel-level events, batch processing completion, recording notifications, and unsupported channel callbacks. These triggers provide visibility into system-level operations and channel-specific notifications that don't fit into standard message or event categories.

The four system triggers are:

- `CHANNEL_EVENT` — Channel-specific notifications (e.g., WhatsApp quality rating)
- `BATCH_STATUS_UPDATE` — Batch message processing completion/failure
- `RECORD_NOTIFICATION` — Recording availability notifications (Voice)
- `UNSUPPORTED` — Raw channel callbacks not mapped to Conversation API

## CHANNEL_EVENT

### Overview

Delivers channel-specific notifications that are unique to particular messaging channels, such as WhatsApp Business quality rating changes or phone number status updates.

### When It Fires

- WhatsApp Business Account quality rating changes
- WhatsApp phone number status changes
- Channel provider sends platform-specific notifications
- Varies by channel; not all channels generate channel events

### Callback Structure

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T14:30:00.123Z",
  "project_id": "PROJECT123",
  "channel_event": {
    "channel_identity": {
      "channel": "WHATSAPP",
      "identity": "46732001122",
      "app_id": "01H1234567..."
    },
    "event_type": "QUALITY_UPDATE",
    "additional_data": {
      "quality_rating": "YELLOW",
      "previous_rating": "GREEN"
    }
  }
}
```

### Common Event Types

**WhatsApp Quality Rating:**

- `quality_rating`: `GREEN`, `YELLOW`, `RED`
- Indicates messaging quality score from WhatsApp
- `RED` rating can lead to restricted messaging limits

**WhatsApp Phone Number Status:**

- Phone number verified, restricted, or deleted
- Certificate renewal required
- Display name approval status

### Common Use Cases

1. **Quality Monitoring** — Alert administrators when WhatsApp quality rating drops
2. **Compliance Management** — Track phone number verification status changes
3. **Proactive Issue Resolution** — React to channel restrictions before they impact users
4. **Channel Health Dashboards** — Display real-time channel status and quality metrics
5. **Automated Remediation** — Reduce sending volume when quality rating drops to prevent restrictions

### Example Payloads

#### WhatsApp Quality Rating Change

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T14:30:00.123Z",
  "project_id": "PROJECT123",
  "channel_event": {
    "channel_identity": {
      "channel": "WHATSAPP",
      "identity": "46732001122",
      "app_id": "01H1234567..."
    },
    "event_type": "QUALITY_UPDATE",
    "additional_data": {
      "quality_rating": "YELLOW",
      "previous_rating": "GREEN",
      "reason": "High block rate detected"
    }
  }
}
```

#### WhatsApp Phone Number Status

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T15:00:00.456Z",
  "project_id": "PROJECT123",
  "channel_event": {
    "channel_identity": {
      "channel": "WHATSAPP",
      "identity": "46732001122",
      "app_id": "01H1234567..."
    },
    "event_type": "PHONE_NUMBER_UPDATE",
    "additional_data": {
      "status": "CONNECTED",
      "verified_name": "APPROVED",
      "display_name": "Acme Corp Support"
    }
  }
}
```

## BATCH_STATUS_UPDATE

### Overview

Notifies when batch message processing completes or fails. Batch sends allow sending messages to multiple recipients in a single API call, and this trigger provides status updates for the entire batch operation.

### When It Fires

- Batch processing completes successfully
- Batch processing fails
- Partial batch completion with some failures

### Callback Structure

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T16:00:00.789Z",
  "project_id": "PROJECT123",
  "batch_status_update": {
    "batch_id": "01H9876543...",
    "status": "COMPLETED",
    "total_messages": 1000,
    "successful_messages": 985,
    "failed_messages": 15,
    "processing_time_ms": 45000
  }
}
```

### Status Values

| Status      | Description                                       |
| ----------- | ------------------------------------------------- |
| `COMPLETED` | Batch fully processed (may include some failures) |
| `FAILED`    | Batch processing failed entirely                  |
| `PARTIAL`   | Some messages processed, some failed              |

### Common Use Cases

1. **Batch Monitoring** — Track completion of bulk message campaigns
2. **Campaign Analytics** — Measure batch send success rates
3. **Failure Handling** — Identify and retry failed messages in a batch
4. **Performance Tracking** — Monitor batch processing times
5. **Notification** — Alert campaign managers when bulk sends complete

### Example Payloads

#### Successful Batch Completion

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T16:30:00.123Z",
  "project_id": "PROJECT123",
  "batch_status_update": {
    "batch_id": "01H9876543...",
    "status": "COMPLETED",
    "total_messages": 5000,
    "successful_messages": 5000,
    "failed_messages": 0,
    "processing_time_ms": 120000
  }
}
```

#### Partial Batch Failure

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T17:00:00.456Z",
  "project_id": "PROJECT123",
  "batch_status_update": {
    "batch_id": "01H8888888...",
    "status": "PARTIAL",
    "total_messages": 1000,
    "successful_messages": 850,
    "failed_messages": 150,
    "processing_time_ms": 60000,
    "failure_reasons": [
      {
        "reason": "RECIPIENT_NOT_REACHABLE",
        "count": 120
      },
      {
        "reason": "INVALID_IDENTITY",
        "count": 30
      }
    ]
  }
}
```

## RECORD_NOTIFICATION

### Overview

Notifies when call recordings are available for download. Used with Sinch Voice API when call recording is enabled. The notification includes a URL to download the recording file.

### When It Fires

- Call recording completes and file is available for download
- Recording processing finishes (transcoding, storage)

### Callback Structure

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T18:00:00.123Z",
  "project_id": "PROJECT123",
  "record_notification": {
    "call_id": "abc123def456",
    "recording_id": "rec_789xyz",
    "recording_url": "https://storage.sinch.com/recordings/rec_789xyz.mp3",
    "duration_seconds": 180,
    "format": "mp3"
  }
}
```

### Common Use Cases

1. **Call Recording Storage** — Download and archive recordings to your own storage
2. **Compliance Archival** — Store recordings for regulatory compliance
3. **Quality Assurance** — Process recordings for agent performance review
4. **Transcription** — Send recordings to transcription services
5. **Analytics** — Extract insights from call recordings

### Example Payload

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T18:30:00.456Z",
  "project_id": "PROJECT123",
  "record_notification": {
    "call_id": "abc123def456",
    "recording_id": "rec_789xyz",
    "recording_url": "https://storage.sinch.com/recordings/rec_789xyz.mp3",
    "duration_seconds": 245,
    "format": "mp3",
    "created_at": "2024-06-15T18:25:00.000Z",
    "expires_at": "2024-06-22T18:25:00.000Z"
  }
}
```

## UNSUPPORTED

### Overview

Delivers raw channel callbacks that are not mapped to standard Conversation API triggers. This is a catch-all trigger for channel-specific events that don't fit into other trigger categories. Useful for debugging and accessing channel-native features not yet abstracted by Conversation API.

### When It Fires

- Channel sends a callback type not recognized by Conversation API
- New channel features not yet supported in Conversation API
- Channel-specific events with no standard mapping

### Callback Structure

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T19:00:00.789Z",
  "project_id": "PROJECT123",
  "unsupported": {
    "channel": "WHATSAPP",
    "payload": {
      // Raw channel-specific payload
      "type": "new_feature_notification",
      "data": {
        // Channel-native structure
      }
    }
  }
}
```

### Common Use Cases

1. **Early Access Features** — Access new channel features before Conversation API support
2. **Debugging** — Inspect raw channel callbacks for troubleshooting
3. **Channel-Native Integration** — Build custom logic for channel-specific events
4. **Future-Proofing** — Handle new channel events as they're introduced
5. **Direct Channel API Mapping** — Maintain compatibility with direct channel API implementations

### Example Payloads

#### Unknown WhatsApp Event

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T19:30:00.123Z",
  "project_id": "PROJECT123",
  "unsupported": {
    "channel": "WHATSAPP",
    "channel_identity": {
      "channel": "WHATSAPP",
      "identity": "46732001122",
      "app_id": "01H1234567..."
    },
    "payload": {
      "type": "account_update",
      "account_id": "123456789",
      "update_type": "display_name_change",
      "new_display_name": "Acme Corp Customer Service"
    }
  }
}
```

#### Unknown RCS Event

```json
{
  "app_id": "01H1234567...",
  "accepted_time": "2024-06-15T20:00:00.456Z",
  "project_id": "PROJECT123",
  "unsupported": {
    "channel": "RCS",
    "channel_identity": {
      "channel": "RCS",
      "identity": "15551234567",
      "app_id": "01H1234567..."
    },
    "payload": {
      "type": "suggestion_selected",
      "message_id": "msg_abc123",
      "suggestion_chip_id": "chip_xyz789"
    }
  }
}
```

## Key Points

### CHANNEL_EVENT

1. **WhatsApp Specific** — Most commonly used for WhatsApp Business quality and status events
2. **Quality Rating Impact** — `RED` rating can severely limit messaging; `YELLOW` is a warning
3. **Proactive Monitoring** — Monitor quality ratings to prevent restrictions before they happen
4. **Channel-Dependent** — Event types and structure vary by channel

### BATCH_STATUS_UPDATE

5. **Async Processing** — Batch processing is asynchronous; this trigger provides completion notification
6. **Partial Failures** — Even `COMPLETED` status can include failed messages; check `failed_messages` count
7. **Failure Analysis** — Use `failure_reasons` to understand why messages failed in the batch
8. **Performance Metrics** — `processing_time_ms` helps optimize batch sizes and timing

### RECORD_NOTIFICATION

9. **Voice API Only** — Only relevant when using Sinch Voice API with recording enabled
10. **Temporary URLs** — Recording URLs typically expire after 7 days; download and store recordings promptly
11. **Format Support** — Recordings available in MP3 or WAV format depending on configuration
12. **Compliance** — Ensure proper consent and disclosure before recording calls (legal requirement)

### UNSUPPORTED

13. **Last Resort** — Only use when specific trigger not available; most use cases covered by standard triggers
14. **Channel-Specific** — Payload structure entirely dependent on the channel; refer to channel documentation
15. **Debugging Tool** — Valuable for understanding what raw data channels send
16. **Version-Dependent** — As Conversation API evolves, events may move from `UNSUPPORTED` to dedicated triggers
17. **No Guarantee** — Channel providers can change callback structure without notice; validate payload before processing

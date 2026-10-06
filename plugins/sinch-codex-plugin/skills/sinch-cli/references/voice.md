> **Summary — not the spec.** This file orients you to a CLI command family. The
> authoritative source for exact flags and argument order is `sinch <cmd> --help` on
> the installed binary; the linked `developers.sinch.com` docs are authoritative for
> concepts but may lag the shipped CLI. Do **not** copy a flag name, argument order, or
> enum value from here into a shipped script without confirming it against `--help`.
> See "Source of Truth" in this skill's SKILL.md.

# Voice CLI — calls and services

Reference for the `sinch voice` command tree. Loaded on-demand from [SKILL.md](../SKILL.md).

`sinch voice` targets Voice API v2. The older Voice API v1 lives under `sinch voice v1` and is covered at the end of this file. Every command supports `--json`.

v2 has no voice-application concept and no application key: `sinch voice calls` and `sinch voice services` authenticate with the project Access Key pair that `sinch auth login` stores. Inbound routing is a **service** — a number is bound to one by its RTC application id, which is the service id.

## Services — inbound call routing

A service holds the webhook URL that inbound calls for its numbers are posted to. A function opts into v2 routing by declaring `VOICE_SERVICE_ID`; `sinch functions deploy` then makes the same `services update` call for you.

```bash
sinch voice services list                              # services in this project
sinch voice services create --name "Support IVR"       # prompts for what it needs
sinch voice services create --name "Support IVR" --webhook-url https://fn-abc123.functions.sinch.com
sinch voice services update <service-id> --webhook-url https://fn-abc123.functions.sinch.com
sinch voice services delete <service-id> --force
```

**`create` flags:** `--name <name>`, `--description <text>`, `--webhook-url <url>` (setting it sets the service's call behavior to `WEBHOOK`), `--json`, `--non-interactive`

**`update` flags:** `--webhook-url <url>` (required)

**`delete` flags:** `--force`, `--json`, `--non-interactive`. The service id is optional; omit it and the CLI prompts.

## Calls — place, inspect and control calls

```bash
# List and inspect
sinch voice calls list --service-id <id> --call-result IN_PROGRESS
sinch voice calls get <call-id>                        # call ID is a ULID

# Place a call
sinch voice calls create +15551234567 --from +15559876543
sinch voice calls create +15551234567 --stream wss://example.com/media --sample-rate 16000
sinch voice calls create +15551234567 --relay <endpoint> --tts-voice <name> --stt-language en-US

# Call two parties and bridge them
sinch voice calls bridge +15551234567 +15551234568 --from +15559876543

# Control a live call
sinch voice calls patch <target> --dial +15551234569 --bridge-name room-42
sinch voice calls hangup <target> --leg caller
```

**`list` flags:** `--service-id <id>`, `--from <number>`, `--to <number>`, `--call-type <type>` (`PHONE`, `SIP`, `STREAM`, `VOICE_RELAY`), `--call-result <result>` (`QUEUED`, `INITIATED`, `IN_PROGRESS`, `COMPLETED`, `REJECTED`, `NO_ANSWER`, `CANCEL`, `BUSY`, `FAILED`), `--start-time <iso>`, `--end-time <iso>`, `-l, --limit <number>`, `--page <number>`

**`create` flags:** `--from <origin>`, `--stream <endpoint>`, `--relay <endpoint>`, `--sample-rate <hz>`, `--tts-voice <name>`, `--stt-language <tag>`, `--no-interruptions`, `--header <key=value>` (repeatable), `--bridge-name <name>`, `--timeout <seconds>`, `--max-duration <seconds>`, `--dry-run`

**`bridge` flags:** `--from <origin>`, `--bridge-name <name>`, `--timeout <seconds>`, `--max-duration <seconds>`, `--dry-run`

**`patch` flags:** `--call-name <name>`, `--dial <destination>`, `--end-leg <name>`, `--dial-leg <name>`, `--bridge-name <name>`, `--from <origin>`, `--timeout <seconds>`, `--commands <source>`, `--dry-run`

**`hangup` flags:** `--call-name <name>`, `--leg <name>` (repeatable), `--dry-run`

`patch` runs commands against a call that is already up — adding a party to it, or sending raw v2 commands with `--commands`. Voice v1 has no equivalent. Use `--dry-run` on any of `create`, `bridge`, `patch` and `hangup` to print the request without sending it.

## Voice v1 (legacy)

`sinch voice v1` is the previous tree, unchanged: applications, callouts, calls and conferences. These commands require a Voice Application Key and Secret. `sinch auth login` no longer collects that pair — supply it with `sinch secrets add VOICE_APPLICATION_SECRET <value>` and pass `-a, --app-key <key>` where the command accepts it.

```bash
# Applications — callback URLs and number assignments
sinch voice v1 applications callbacks get
sinch voice v1 applications callbacks set https://fn-abc123.functions.sinch.com --fallback https://backup.example.com
sinch voice v1 applications numbers list
sinch voice v1 applications numbers assign +15551234567 --capability voice
sinch voice v1 applications numbers unassign +15551234567

# Callouts — place outbound calls
sinch voice v1 callouts tts +15551234567 "Your package is arriving today" --voice en-US --cli +15559876543
sinch voice v1 callouts conference +15551234567 room-42 --greeting "Joining the sales call" --moh music1
sinch voice v1 callouts custom +15551234567 --ice @./ice-payload.json

# Calls — query and control in-progress calls
sinch voice v1 calls get <call-id>
sinch voice v1 calls hangup <call-id>
sinch voice v1 calls update <call-id> --svaml @./svaml.json
sinch voice v1 calls manage-leg <call-id> --leg caller --svaml @./say.json

# Conferences — rooms and participants
sinch voice v1 conferences get room-42
sinch voice v1 conferences kick room-42 <call-id>
sinch voice v1 conferences kick-all room-42 --yes
sinch voice v1 conferences manage room-42 <call-id> --hold --moh music1
```

**TTS callout flags:** `--voice <locale>`, `--cli <number>`, `--dtmf <seq>`, `--domain pstn|mxp`, `--enable-ace`, `--enable-dice`, `--enable-pie`

**Conference callout flags:** `--cli`, `--greeting`, `--locale`, `--moh ring|music1|music2|music3`, `--max-duration`, `--dtmf`, `--domain`

**Custom callout flags:** `--ice <svaml|@file>`, `--ace <svaml|@file>`, `--pie <svaml|@file>`, `--cli`, `--dtmf`, `--max-duration` (at least one of `--ice`, `--ace`, or `--pie` is required)

**`conferences manage`** action flags (exactly one required): `--mute`, `--unmute`, `--hold`, `--resume`. Use `--moh <music>` with `--hold`. Participants are identified by their per-leg call ID from `conferences get`, not by phone number. To play audio or speak text to a participant, use `sinch voice v1 calls manage-leg` instead — those hit a different SDK method.

`sinch voice v1 applications numbers` manages the numbers attached to a specific Voice application. For the account-wide number inventory (search, rent, release), use `sinch numbers` — see [numbers-and-porting.md](numbers-and-porting.md).

## Related

- [CLI skill](../SKILL.md) — full CLI overview
- [numbers-and-porting.md](numbers-and-porting.md) — account-wide phone number inventory
- [Voice CLI docs](https://developers.sinch.com/docs/functions/cli/commands/voice.md)

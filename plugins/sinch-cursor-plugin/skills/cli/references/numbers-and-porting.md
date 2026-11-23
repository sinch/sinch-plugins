> **Summary — not the spec.** This file orients you to a CLI command family. The
> authoritative source for exact flags and argument order is `sinch <cmd> --help` on
> the installed binary; the linked `developers.sinch.com` docs are authoritative for
> concepts but may lag the shipped CLI. Do **not** copy a flag name, argument order, or
> enum value from here into a shipped script without confirming it against `--help`.
> See "Source of Truth" in this skill's SKILL.md.

# Numbers and Porting CLI

Reference for `sinch numbers` (account-wide phone number inventory) and `sinch porting` (move numbers in/out of Sinch). Loaded on-demand from [SKILL.md](../SKILL.md).

## Phone numbers (`sinch numbers`)

```bash
# Search available numbers
sinch numbers available --region US --type LOCAL --capability SMS VOICE
sinch numbers available --region US --pattern 555 --rent     # interactive rent

# List numbers you already rent
sinch numbers active list
sinch numbers active list --region US --json

# Get details + update configuration
sinch numbers active get +15551234567
sinch numbers active update +15551234567 \
  --display-name "Main Line" \
  --voice-app app_abc123 \
  --sms-service-plan sps_xyz

# Release a number
sinch numbers active release +15551234567 --force

# List supported regions
sinch numbers regions --type MOBILE
```

**Region codes** are ISO country codes: `US`, `GB`, `SE`, etc. **Number types:** `LOCAL`, `MOBILE`, `TOLL_FREE`. **Capabilities:** `SMS`, `VOICE` (repeatable).

### `sinch numbers active update` flags

| Flag | Description |
|---|---|
| `-d, --display-name <name>` | Human-readable label |
| `--voice-app <id>` | Voice application ID to route voice traffic to |
| `--sms-service-plan <id>` | SMS service plan ID (empty string to unlink) |
| `--callback-url <url>` | Callback URL for provisioning events |

### `sinch numbers available` flags

| Flag | Description |
|---|---|
| `-r, --region <code>` | ISO country code (required for useful results) |
| `-t, --type <type>` | `LOCAL` / `MOBILE` / `TOLL_FREE` |
| `-c, --capability <cap...>` | `SMS` / `VOICE` (repeatable) |
| `-p, --pattern <digits>` | Digit pattern to search |
| `-l, --limit <n>` | Max results |
| `--rent` | Interactively choose and rent from results |

## Porting (`sinch porting`)

Port existing phone numbers from another carrier into Sinch. The porting tree has five subgroups: `check`, `config`, `orders`, `documents`, `activation`.

```bash
# Check if numbers are portable to Sinch
sinch porting check +15551234567 +15551234568

# Project-level porting configuration (contact info, webhook, default port times)
sinch porting config get
sinch porting config update

# Port-in orders
sinch porting orders create                    # interactive
sinch porting orders list
sinch porting orders get <order-id>
sinch porting orders update <order-id>
sinch porting orders cancel <order-id>
sinch porting orders add-note <order-id>

# Supporting documents
sinch porting documents upload <order-id>
sinch porting documents get <order-id> <doc-id>

# Activation (final step — switch traffic to the ported numbers)
sinch porting activation list <order-id>       # list activation groups
sinch porting activation activate <order-id>   # activate (optionally by group)
```

### Typical port-in flow

1. **Check portability** — `sinch porting check +15551234567` confirms the number can be ported
2. **Update config** — `sinch porting config update` sets your contact info and status webhook
3. **Create order** — `sinch porting orders create` starts a port-in (interactive)
4. **Upload documents** — `sinch porting documents upload <order-id>` for any supporting paperwork the losing carrier requires
5. **Wait for approval** — monitor `sinch porting orders get <order-id>`
6. **Activate** — `sinch porting activation activate <order-id>` switches traffic to the ported numbers

All porting commands support `--json` for machine-readable output and OAuth2 credentials from `sinch auth login`.

## Related

- [CLI skill](../SKILL.md) — full CLI overview
- [Numbers CLI docs](https://developers.sinch.com/docs/functions/cli/commands/numbers.md)
- [Porting CLI docs](https://developers.sinch.com/docs/functions/cli/commands/porting.md)
- [Sinch Numbers API](https://developers.sinch.com/docs/numbers.md)

# Operation Randomize

Welcome, agent. Somewhere on this sandbox network sits a password-protected **vault**. Its hostname, its port, its password, the key you register your session under and the namespace you claim in it were all **generated for your sandbox alone** by the five Labs 2.0 randomizers:

| Randomizer | What it generates | Your mission |
|---|---|---|
| `random_creature` | A friendly `adjective-animal` name | Find the vault by its hostname |
| `random_number` | An integer between `minimum` and `maximum` | Knock on the vault's random port |
| `random_password` | A password with configurable character classes | Unlock the vault and store your PIN |
| `random_uuid` | An RFC 4122 v4 UUID | Register a globally unique session |
| `random_id` | Random bytes as `hex`, `dec` and `base64` | Claim a tenant namespace |

The capstone then combines all five into one deployment.

## How the values reach you

The randomizers live in `sandbox.hcl`. Each value is generated **once**, when the sandbox is created, and then stays the same for the whole session. From there it travels three ways:

1. **Into containers** through `environment = { ... }`, so every value is a `LAB_*` environment variable on your workstation.
2. **Into these instructions** through a page's `variables = { ... }` map. That is why the values below are yours and nobody else's.
3. **Into other resources**, for example as the vault's network alias, port and `--requirepass` argument.

Here is what was generated for you:

| | Value |
|---|---|
| Creature | `{{creature}}` |
| Vault hostname | `{{vaultHost}}` |
| Vault port | `{{vaultPort}}` |
| Shard count | `{{shardCount}}` |
| Session ID | `{{sessionId}}` |
| Tenant ID (hex) | `{{tenantHex}}` |
| Password and PIN | *Hidden on purpose. Secrets never go into instructions.* |

## Your tools

| Tab | What it is |
|---|---|
| **Workstation** | Your shell. `redis-cli` is installed. The prompt shows your creature name. |
| **Vault Server** | A shell on the vault container, for looking behind the curtain. |
| **Editor** | The files in `/root/workspace`, where your task answers go. |
| **Cheat Sheet** | Every randomizer's fields and attributes on one page. |

## Warm-up

In the **Workstation** tab, list everything that was generated:

```bash
lab-values
```

Now look at the raw environment variables that `sandbox.hcl` injected:

```bash
env | grep ^LAB_ | sort
```

> **Why do they match?** The values in `lab-values` and the table above come from the same resources. The instructions use `{{lb}}creature}}` placeholders filled by page `variables`, and the container uses `environment`. One source, two destinations.

When you're ready, move on to the first randomizer.

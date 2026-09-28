# Capstone: deploy the shards

Time to use all five randomizers together. You'll deploy a sharded dataset into the vault and publish a deployment manifest that other teams can read. It must contain **no secrets**.

| Input | Randomizer | Your value |
|---|---|---|
| Where to deploy | `random_creature` + `random_number` | `{{vaultHost}}:{{vaultPort}}` |
| How to authenticate | `random_password` | `$REDISCLI_AUTH` |
| How many shards | `random_number` | `{{shardCount}}` |
| Shard key prefix | `random_uuid` + `substr()` | `shard:{{sessionShort}}:` |
| Tenant | `random_id` | `{{tenantHex}}` |

## Step 1: deploy exactly {{shardCount}} shards

Create keys `shard:{{sessionShort}}:1` through `shard:{{sessionShort}}:{{shardCount}}`. Each key holds your vault hostname, `{{vaultHost}}`. The count comes from a randomizer, so let a loop read it instead of hard-coding it:

```bash
export REDISCLI_AUTH="$LAB_VAULT_PASSWORD"
alias vault="redis-cli -h $LAB_VAULT_HOST -p $LAB_VAULT_PORT"

for i in $(seq 1 "$LAB_SHARD_COUNT"); do
  vault SET "shard:$LAB_SESSION_SHORT:$i" "$LAB_VAULT_HOST"
done

vault --scan --pattern "shard:$LAB_SESSION_SHORT:*" | sort
```

The check wants **exactly** {{shardCount}} shard keys. Delete any extras with `vault DEL <key>`.

## Step 2: publish a safe manifest

Create `/root/workspace/manifest.env` with these four lines, and nothing secret:

```
VAULT_HOST={{vaultHost}}
VAULT_PORT={{vaultPort}}
SESSION_ID={{sessionId}}
TENANT_ID={{tenantHex}}
```

Generate it from the environment rather than typing it:

```bash
cat > /root/workspace/manifest.env <<EOF
VAULT_HOST=$LAB_VAULT_HOST
VAULT_PORT=$LAB_VAULT_PORT
SESSION_ID=$LAB_SESSION_ID
TENANT_ID=$LAB_TENANT_HEX
EOF
cat /root/workspace/manifest.env
```

Extra lines, such as `SHARDS=...`, are fine. The check **fails** if the vault password or the PIN appears anywhere in the file. Want to see the guard work? Add `VAULT_PASSWORD=$LAB_VAULT_PASSWORD`, click **Check**, then remove the line again.

<instruqt-task id="deploy_shards"></instruqt-task>

## Final debrief: pick the right randomizer

<instruqt-quiz id="final_quiz"></instruqt-quiz>

## What you built

| Randomizer | Field(s) you used | Output | Where it went |
|---|---|---|---|
| `random_creature` | — | `value` | DNS alias, prompt, badge |
| `random_number` | `minimum`, `maximum` | `value` (number) | Port, shard count |
| `random_password` | `length`, `min_*`, `override_special`, class toggles | `value` | `--requirepass`, PIN |
| `random_uuid` | — | `value` | Session key, short ID via `substr()` |
| `random_id` | `byte_length` | `hex`, `dec`, `base64` | Tenant namespace |

And the patterns that make them useful in real labs:

- **Environment injection:** `environment = { X = resource.random_*.name.value }`
- **Personalized instructions:** page `variables` and `{{lb}}creature}}`-style placeholders (camelCase names)
- **Type conversion:** `tostring()` for numbers in string fields
- **Derivation:** `lower()` and `substr()` to shape values
- **Secret hygiene:** `min_*` for policies, `override_special` for safe symbols, `REDISCLI_AUTH` instead of `-a`, and never putting secrets in instructions or manifests
- **Robust checks:** read expected values from the environment. Never hard-code a random value.

> **Challenge:** fork this lab and add a second `random_creature` for a "replica" container, or use `random_number` to pick one of several quiz variants.

<instruqt-completion text="Mission complete, {{creature}}. You used all five Labs 2.0 randomizers to build a one-of-a-kind sandbox."></instruqt-completion>

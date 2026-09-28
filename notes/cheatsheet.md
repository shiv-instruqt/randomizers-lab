# Randomizer Cheat Sheet

All five are sandbox resources. Each value is generated once, when the sandbox is created, and stays stable for the session.

## random_creature

```hcl
resource "random_creature" "name" {}
```

| Attribute | Type | Example |
|---|---|---|
| `value` | string | `brave-dolphin` |

Use for hostnames, labels and friendly names. Not for secrets or guaranteed uniqueness.

## random_number

```hcl
resource "random_number" "name" {
  minimum = 10000   # required, value >= minimum
  maximum = 65535   # required, value <= maximum
}
```

| Attribute | Type |
|---|---|
| `value` | **number**. Wrap it in `tostring()` for string fields |

Use for ports, counts, weights and subnet octets.

## random_password

```hcl
resource "random_password" "name" {
  length           = 16      # required
  upper            = true    # allow class (default true)
  lower            = true
  numeric          = true
  special          = true
  min_upper        = 1       # guarantee class (default 0)
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "@#%+=" # custom symbol set
}
```

| Attribute | Type |
|---|---|
| `value` | string (sensitive) |

Allowing a class isn't the same as guaranteeing it. Use `min_*` for any password policy.

## random_uuid

```hcl
resource "random_uuid" "name" {}
```

| Attribute | Type | Example |
|---|---|---|
| `value` | string | `550e8400-e29b-41d4-a716-446655440000` |

Use for globally unique keys and correlation IDs. Shorten with `substr(value, 0, 8)`.

## random_id

```hcl
resource "random_id" "name" {
  byte_length = 8   # required, 1-256
}
```

| Attribute | Type | Notes |
|---|---|---|
| `hex` | string | 2 x `byte_length` characters |
| `dec` | string | The same bytes as a decimal integer |
| `base64` | string | The same bytes, base64-encoded |

Use for non-sensitive suffixes and namespaces. 8–16 bytes is typical.

## Wiring patterns

```hcl
# Into a container
environment = {
  PORT = tostring(resource.random_number.port.value)
  NAME = lower(resource.random_creature.name.value)
}

# Into instructions (page variables, camelCase keys)
variables = {
  hostName = lower(resource.random_creature.name.value)
}

# Into other resources
aliases = [lower(resource.random_creature.name.value)]
port {
  local = resource.random_number.port.value
}
```

## Handy commands in this lab

| Command | What it does |
|---|---|
| `lab-values` | Show all generated values (secrets masked) |
| `lab-values --reveal` | Show secrets too |
| `export REDISCLI_AUTH="$LAB_VAULT_PASSWORD"` | Authenticate redis-cli safely |
| `alias vault="redis-cli -h $LAB_VAULT_HOST -p $LAB_VAULT_PORT"` | Shortcut to the vault |

Docs: https://docs.labs.instruqt.com/reference/

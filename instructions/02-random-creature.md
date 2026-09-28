# random_creature: find the vault

`random_creature` generates a friendly, URL-safe name in `adjective-animal` style. It has **no arguments** and one computed attribute, `value`.

Your sandbox got **`{{creature}}`**.

## The HCL behind it

```hcl
resource "random_creature" "mascot" {}
```

The name is then used in two places in `sandbox.hcl`:

```hcl
# 1. As a DNS alias for the vault on the sandbox network
resource "container" "vault" {
  network {
    id      = resource.network.main.meta.id
    aliases = [lower(resource.random_creature.mascot.value), "vault"]
  }
}

# 2. As an environment variable on your workstation
resource "container" "workstation" {
  environment = {
    LAB_CREATURE   = resource.random_creature.mascot.value
    LAB_VAULT_HOST = lower(resource.random_creature.mascot.value)
  }
}
```

`lower()` is one of the HCL string functions. Hostnames are case-insensitive, but wrapping the value in `lower()` keeps the hostname predictable no matter what casing the generator returns.

## Hands-on

1. Print your creature name. Your prompt already shows it:

    ```bash
    echo "$LAB_CREATURE"
    ```

2. The creature name is now a **hostname**. Resolve it:

    ```bash
    getent hosts {{vaultHost}}
    ```

    You get the vault container's IP address. No IP was hard-coded anywhere. The alias came from a randomizer.

3. Knock on the vault. It answers, but it won't let you in yet:

    ```bash
    redis-cli -h {{vaultHost}} -p "$LAB_VAULT_PORT" ping
    ```

    `NOAUTH Authentication required` means you found the right host. The port and the password come in the next two chapters.

## When to use random_creature

| Good fit | Poor fit |
|---|---|
| Hostnames, container names, labels | Passwords, tokens and keys (use `random_password`) |
| Names people read aloud in a workshop | Guaranteed-unique IDs (use `random_uuid`) |
| Friendlier log lines than a UUID | Anything a script must parse strictly |

A creature name is memorable, not secret. Only `random_password` and `random_id` are documented as cryptographically secure.

## Task: get your badge

Write your creature name, and nothing else, to `/root/workspace/badge.txt`. Use the environment variable. Don't type the name by hand:

```bash
echo "$LAB_CREATURE" > /root/workspace/badge.txt
cat /root/workspace/badge.txt
```

<instruqt-task id="creature_badge"></instruqt-task>

## Check your understanding

<instruqt-quiz id="creature_quiz"></instruqt-quiz>

> **Try this:** open the **Cheat Sheet** tab. It lists the attributes of all five randomizers, and you'll use it for the rest of the lab.

# random_password: unlock the vault

`random_password` generates a cryptographically secure password. Only `length` is required. The other fields shape the character set:

| Field | Type | Default | Purpose |
|---|---|---|---|
| `length` | number | *required* | Total number of characters |
| `upper` / `lower` / `numeric` / `special` | bool | `true` | Allow that character class |
| `min_upper` / `min_lower` / `min_numeric` / `min_special` | number | `0` | **Guarantee** at least this many from that class |
| `override_special` | string | — | Replace the special-character set with exactly these characters |

The result is in `value`.

## The HCL behind it

```hcl
resource "random_password" "vault" {
  length = 20

  min_special = 2
  min_numeric = 2
  min_lower   = 2
  min_upper   = 2

  override_special = "@#%+="
}

# A digits-only PIN: switch every class off except numeric
resource "random_password" "pin" {
  length  = 6
  special = false
  upper   = false
  lower   = false
  numeric = true
}
```

The vault password is passed to the server as `--requirepass`, and to your workstation as `LAB_VAULT_PASSWORD`. The PIN only goes to your workstation, as `LAB_VAULT_PIN`.

## Lesson from the field: allowed isn't guaranteed

`upper = true` means uppercase letters **may** appear, not that they **will**. A real lab generated account passwords with:

```hcl
resource "random_password" "user" {
  length  = 16
  special = false
}
```

The identity provider required at least three of four character classes. With symbols switched off, every password needed upper, lower **and** a digit. The chance that 16 random alphanumeric characters contain no digit at all is (52/62)^16, **about 6%**. So roughly one in sixteen sandboxes failed to start. The fix was one line per class:

```hcl
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
```

**Rule of thumb:** whenever the target system has a password policy, express it with `min_*`.

`override_special` solves the other classic problem. The default special set includes characters like `$`, `&` and `*` that mean something to shells, URLs and config files. Restricting the set to `@#%+=` keeps the password safe to paste almost anywhere.

## Hands-on

1. Secrets are masked by default:

    ```bash
    lab-values
    lab-values --reveal
    ```

2. Audit the password against its policy:

    ```bash
    p="$LAB_VAULT_PASSWORD"
    echo "length : ${#p}"
    echo "upper  : $(printf '%s' "$p" | tr -cd 'A-Z' | wc -c)"
    echo "lower  : $(printf '%s' "$p" | tr -cd 'a-z' | wc -c)"
    echo "digits : $(printf '%s' "$p" | tr -cd '0-9' | wc -c)"
    echo "special: $(printf '%s' "$p" | tr -cd '@#%+=' | wc -c)"
    ```

    Every class shows at least 2, as `min_*` promised.

3. Confirm the PIN is digits only:

    ```bash
    echo "$LAB_VAULT_PIN" | grep -Eq '^[0-9]{6}$' && echo "PIN is 6 digits"
    ```

4. **The risky way** to log in puts the password on the command line:

    ```bash
    redis-cli -h {{vaultHost}} -p {{vaultPort}} -a "$LAB_VAULT_PASSWORD" ping
    ```

    `redis-cli` itself warns you. Anything in a command line can show up in process lists and shell history.

5. **The better way** passes it through an environment variable that `redis-cli` reads:

    ```bash
    export REDISCLI_AUTH="$LAB_VAULT_PASSWORD"
    redis-cli -h {{vaultHost}} -p {{vaultPort}} ping
    ```

    `PONG`. You're in.

6. Make the rest of the lab easier with a shortcut:

    ```bash
    alias vault='redis-cli -h {{vaultHost}} -p {{vaultPort}}'
    vault ping
    ```

    If you ever open a new terminal, repeat steps 5 and 6.

## Task: store your PIN

Store your PIN in the vault under the key `vault:pin`, then read it back:

```bash
vault SET vault:pin "$LAB_VAULT_PIN"
vault GET vault:pin
```

<instruqt-task id="unlock_vault"></instruqt-task>

## Check your understanding

<instruqt-quiz id="password_quiz"></instruqt-quiz>

> **Security note:** the Labs docs say to always treat password values as sensitive. That's why this lab never passes the password or PIN to the instructions, and why the capstone check fails if either one leaks into a file.

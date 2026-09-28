# random_id: carve out a tenant

`random_id` generates `byte_length` random bytes (1–256) and gives you **the same bytes in three encodings**:

| Attribute | Type | Your value |
|---|---|---|
| `hex` | string | `{{tenantHex}}` |
| `dec` | string | `{{tenantDec}}` |
| `base64` | string | `{{tenantB64}}` |

Hex is always twice `byte_length` characters long. You pick the encoding the target system wants: hex for resource names, decimal for numeric fields or arithmetic, base64 for compact tokens in config files.

## The HCL behind it

```hcl
resource "random_id" "tenant" {
  byte_length = 6
}

resource "container" "workstation" {
  environment = {
    LAB_TENANT_HEX = resource.random_id.tenant.hex
    LAB_TENANT_DEC = resource.random_id.tenant.dec
    LAB_TENANT_B64 = resource.random_id.tenant.base64
  }
}
```

The docs recommend **8 to 16 bytes** for standard identifiers. This lab uses 6, so the decimal form fits into shell arithmetic and you can verify it by hand. The docs also show `dec` in HCL arithmetic, for example building a subnet with `"10.${resource.random_id.network_id.dec % 254 + 1}.0.0/24"`.

`random_id` is for **non-sensitive** identifiers. For credentials, use `random_password`.

## Hands-on: prove it's all one ID

1. Print all three encodings:

    ```bash
    echo "hex   : $LAB_TENANT_HEX"
    echo "dec   : $LAB_TENANT_DEC"
    echo "base64: $LAB_TENANT_B64"
    ```

2. Hex length is `2 x byte_length`:

    ```bash
    printf '%s' "$LAB_TENANT_HEX" | wc -c
    ```

3. Hex to decimal:

    ```bash
    printf '%d\n' "0x$LAB_TENANT_HEX"
    ```

    Compare the result with `$LAB_TENANT_DEC`. It's the same number.

4. Base64 back to hex. The `tr` step also accepts URL-safe base64:

    ```bash
    printf '%s' "$LAB_TENANT_B64" | tr -- '-_' '+/' | base64 -d | od -An -tx1 | tr -d ' \n'; echo
    ```

    Compare the result with `$LAB_TENANT_HEX`.

> **Tester's eye:** if `LAB_TENANT_B64` is empty, or the decoded bytes don't match the hex, the `base64` attribute doesn't behave as documented. That's worth reporting. The task below checks your decoded output against the actual base64 value either way.

## Task: claim your tenant

1. Claim the namespace. The **key** uses the hex form and the **value** is the decimal form:

    ```bash
    vault SET "tenant:$LAB_TENANT_HEX" "$LAB_TENANT_DEC"
    vault GET "tenant:$LAB_TENANT_HEX"
    ```

2. Save the base64 value, decoded to hex, as evidence:

    ```bash
    printf '%s' "$LAB_TENANT_B64" | tr -- '-_' '+/' | base64 -d | od -An -tx1 | tr -d ' \n' > /root/workspace/tenant-decoded.txt
    cat /root/workspace/tenant-decoded.txt; echo
    ```

<instruqt-task id="tenant_namespace"></instruqt-task>

## Check your understanding

<instruqt-quiz id="id_quiz"></instruqt-quiz>

# random_number: knock on the right door

`random_number` generates an integer between two bounds. It has two **required** fields:

| Field | Type | Meaning |
|---|---|---|
| `minimum` | number | The generated value will be **>=** this |
| `maximum` | number | The generated value will be **<=** this |

The result is in `value`, and it's a **number**, not a string.

Your vault listens on port **`{{vaultPort}}`**, and your capstone needs **`{{shardCount}}`** shards.

## The HCL behind it

```hcl
resource "random_number" "vault_port" {
  minimum = 20000
  maximum = 29999
}

resource "random_number" "shard_count" {
  minimum = 3
  maximum = 6
}
```

Here the same number feeds a **number field** and a **string field**:

```hcl
resource "container" "vault" {
  command = [
    "redis-server",
    "--port", tostring(resource.random_number.vault_port.value),   # string list
    # ...
  ]

  port {
    local = resource.random_number.vault_port.value                # number field
  }
}
```

`command` and `environment` expect strings, so the value goes through `tostring()`. `port.local` expects a number, so the value is used as-is.

## Hands-on

1. Read the port from the environment:

    ```bash
    echo "$LAB_VAULT_PORT"
    ```

2. Try the port everyone *expects* Redis to use:

    ```bash
    redis-cli -h {{vaultHost}} -p 6379 ping
    ```

    `Connection refused`. Nothing listens on the default port.

3. Now try the random port:

    ```bash
    redis-cli -h {{vaultHost}} -p {{vaultPort}} ping
    ```

    `NOAUTH`: right door, still locked.

4. Switch to the **Vault Server** tab and see which port the server process reports:

    ```bash
    tr '\0' ' ' < /proc/1/cmdline; echo
    ```

    You should see something like `redis-server *:{{vaultPort}}`. The random number went from `sandbox.hcl`, through `command`, into a running process.

## Why randomize a number?

- **Ports:** avoid collisions when many services or instances share a host.
- **Counts:** vary replicas, shards or workers, so learners can't just memorize an answer.
- **Network values:** subnet octets, VLAN IDs and weights.

Pick bounds your system can handle, and test at both ends of the range.

## Task: record the port

Save the vault's port, digits only, to `/root/workspace/port.txt`:

```bash
echo "$LAB_VAULT_PORT" > /root/workspace/port.txt
```

The check also confirms that something really answers on that port.

<instruqt-task id="find_port"></instruqt-task>

## Check your understanding

<instruqt-quiz id="number_quiz"></instruqt-quiz>

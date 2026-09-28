# random_uuid: register your session

`random_uuid` generates an RFC 4122 **version 4** UUID. Like `random_creature`, it takes **no arguments**, and the result is in `value`.

Your session ID is:

```
{{sessionId}}
```

## The HCL behind it

```hcl
resource "random_uuid" "session" {}

resource "container" "workstation" {
  environment = {
    LAB_SESSION_ID    = resource.random_uuid.session.value
    LAB_SESSION_SHORT = substr(resource.random_uuid.session.value, 0, 8)
  }
}
```

`substr(string, offset, length)` derives a short, readable ID from the full UUID. For you that's **`{{sessionShort}}`**. The docs recommend this pattern: short substrings with a descriptive prefix when the full UUID is too long, such as `lab-queue-{{sessionShort}}`.

## Anatomy of a v4 UUID

```
xxxxxxxx-xxxx-4xxx-Nxxx-xxxxxxxxxxxx
               |    |
               |    +-- variant: always 8, 9, a or b
               +------- version: always 4
```

Of the 128 bits, 122 are random, so collisions are practically impossible. That makes a UUID the right choice when you need **guaranteed global uniqueness**: database keys, correlation IDs, and cloud resource names that must be unique across every lab instance.

## Hands-on

1. Look at the UUID and pull out its version and variant characters:

    ```bash
    echo "$LAB_SESSION_ID"
    echo "version: $(echo "$LAB_SESSION_ID" | cut -c15)"
    echo "variant: $(echo "$LAB_SESSION_ID" | cut -c20)"
    ```

2. Validate the whole format with a regular expression:

    ```bash
    echo "$LAB_SESSION_ID" | grep -Eq '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' \
      && echo "valid RFC 4122 v4 UUID"
    ```

    > **Tester's eye:** the docs promise an RFC 4122 v4 UUID. If your version digit is *not* `4`, or the regex doesn't match, you've found a gap between the docs and the implementation. Write down the value. The task below checks against your actual UUID, so you can still complete it.

3. Confirm the short ID really is the first 8 characters:

    ```bash
    [ "$(echo "$LAB_SESSION_ID" | cut -c1-8)" = "$LAB_SESSION_SHORT" ] && echo "substr() matches"
    ```

## Task: register the session

Use the UUID as a primary key. Create a Redis **hash** called `session:<your UUID>` with a `creature` field and a `short` field. A `started` timestamp is optional.

Make sure `REDISCLI_AUTH` and the `vault` alias from the previous chapter are still set:

```bash
vault HSET "session:$LAB_SESSION_ID" \
  creature "$LAB_CREATURE" \
  short "$LAB_SESSION_SHORT" \
  started "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

vault HGETALL "session:$LAB_SESSION_ID"
```

Then save the UUID's version digit to a file:

```bash
echo "$LAB_SESSION_ID" | cut -c15 > /root/workspace/uuid-version.txt
```

<instruqt-task id="register_session"></instruqt-task>

## Check your understanding

<instruqt-quiz id="uuid_quiz"></instruqt-quiz>

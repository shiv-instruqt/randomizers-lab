# =============================================================================
#  Operation Randomize - sandbox
#
#  Every value that makes this sandbox unique comes from one of the five
#  Labs 2.0 randomizers. Each one is generated once, when the sandbox is
#  created, and then stays the same for the whole session.
#
#  Docs: https://docs.labs.instruqt.com/reference/sandbox/utilities/random/randomcreature/
# =============================================================================

# -----------------------------------------------------------------------------
# 1. random_creature - a friendly, URL-safe "adjective-animal" name.
#    Used as the vault's hostname (network alias) and your shell prompt.
# -----------------------------------------------------------------------------
resource "random_creature" "mascot" {}

# -----------------------------------------------------------------------------
# 2. random_number - an integer between minimum and maximum.
#    Used as the vault's listening port and as a shard count.
# -----------------------------------------------------------------------------
resource "random_number" "vault_port" {
  minimum = 20000
  maximum = 29999
}

resource "random_number" "shard_count" {
  minimum = 3
  maximum = 6
}

# -----------------------------------------------------------------------------
# 3. random_password - a password with configurable character classes.
#    min_* guarantees every class is present (a password policy can never be
#    missed by bad luck) and override_special keeps the symbols shell-safe.
# -----------------------------------------------------------------------------
resource "random_password" "vault" {
  length = 20

  special = true
  numeric = true
  lower   = true
  upper   = true

  min_special = 2
  min_numeric = 2
  min_lower   = 2
  min_upper   = 2

  override_special = "@#%+="
}

# A digits-only PIN: turn every class off except numeric.
resource "random_password" "pin" {
  length  = 6
  special = false
  upper   = false
  lower   = false
  numeric = true
}

# -----------------------------------------------------------------------------
# 4. random_uuid - an RFC 4122 version 4 UUID.
#    Used as the session ID (primary key of the session record in the vault).
# -----------------------------------------------------------------------------
resource "random_uuid" "session" {}

# -----------------------------------------------------------------------------
# 5. random_id - random bytes, exposed as hex, dec and base64.
#    6 bytes -> 12 hex characters, 8 base64 characters, one decimal integer.
# -----------------------------------------------------------------------------
resource "random_id" "tenant" {
  byte_length = 6
}

# =============================================================================
#  Infrastructure
# =============================================================================
resource "network" "main" {
  subnet = "10.0.42.0/24"
}

# The "vault": a password-protected Redis server.
#   hostname -> random_creature   port -> random_number   auth -> random_password
resource "container" "vault" {
  image {
    name = "redis:7.4-bookworm"
  }

  command = [
    "redis-server",
    "--port", "${resource.random_number.vault_port.value}",
    "--requirepass", resource.random_password.vault.value,
    "--save", "",
    "--appendonly", "no",
  ]

  environment = {
    LAB_ROLE = "vault"
  }

  port {
    local = resource.random_number.vault_port.value
  }

  network {
    id = resource.network.main.meta.id
    # The creature name becomes a DNS name on the sandbox network.
    # lower() keeps it a clean hostname whatever casing the generator uses.
    aliases = [lower(resource.random_creature.mascot.value), "vault"]
  }

  health_check {
    timeout = "60s"

    exec {
      command = [
        "sh", "-c",
        "redis-cli -p ${resource.random_number.vault_port.value} -a '${resource.random_password.vault.value}' --no-auth-warning ping | grep -q PONG",
      ]
    }
  }

  resources {
    cpu    = 500
    memory = 256
  }
}

# The workstation you type into. It gets every random value as an
# environment variable, so you can inspect them with `env` or `lab-values`.
resource "container" "workstation" {
  image {
    name = "redis:7.4-bookworm"
  }

  entrypoint = ["/bin/sh"]
  command    = ["/opt/lab/bin/startup.sh"]

  environment = {
    # random_creature
    LAB_CREATURE   = resource.random_creature.mascot.value
    LAB_VAULT_HOST = lower(resource.random_creature.mascot.value)

    # random_number ("${...}" interpolation turns the number into a string)
    LAB_VAULT_PORT  = "${resource.random_number.vault_port.value}"
    LAB_SHARD_COUNT = "${resource.random_number.shard_count.value}"

    # random_password
    LAB_VAULT_PASSWORD = resource.random_password.vault.value
    LAB_VAULT_PIN      = resource.random_password.pin.value

    # random_uuid (+ substr() to derive a short ID from it)
    LAB_SESSION_ID    = resource.random_uuid.session.value
    LAB_SESSION_SHORT = substr(resource.random_uuid.session.value, 0, 8)

    # random_id - the same 6 random bytes in three encodings
    LAB_TENANT_HEX = resource.random_id.tenant.hex
    LAB_TENANT_DEC = resource.random_id.tenant.dec
    LAB_TENANT_B64 = resource.random_id.tenant.base64
  }

  # Helper scripts (startup.sh, lab-values) shipped with the lab repo.
  volume {
    source      = "files"
    destination = "/opt/lab"
    read_only   = true
  }

  network {
    id      = resource.network.main.meta.id
    aliases = ["workstation"]
  }

  resources {
    cpu    = 500
    memory = 256
  }

  # Wait until the vault answers PONG before starting the workstation.
  depends_on = [resource.container.vault]
}

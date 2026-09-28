# All checks run on the workstation. Scripts are POSIX sh (task scripts are
# executed with `sh -c`), and they read the random values from the
# workstation's environment - so a check never hard-codes a value.
#
# Convention: scripts/task/<task_name>/<script>.sh

resource "task" "creature_badge" {
  description     = "Write your creature name to /root/workspace/badge.txt"
  success_message = "Badge issued! Your sandbox now has a name nobody else is likely to share."

  config {
    target  = resource.container.workstation
    timeout = "30s"
  }

  condition "badge_matches" {
    description = "badge.txt contains exactly your random_creature value"

    check {
      script          = "scripts/task/creature_badge/check.sh"
      failure_message = "badge.txt must contain exactly the value of $LAB_CREATURE (one line, nothing else)."
    }

    solve {
      script = "scripts/task/creature_badge/solve.sh"
    }
  }

  condition "vault_resolves" {
    description = "The creature hostname resolves on the sandbox network"

    check {
      script          = "scripts/task/creature_badge/check_dns.sh"
      failure_message = "The vault hostname does not resolve yet. Run: getent hosts $LAB_VAULT_HOST"
    }
  }
}

resource "task" "find_port" {
  description     = "Record the vault's random port in /root/workspace/port.txt"
  success_message = "Right door, first knock. That port was picked just for this sandbox."

  config {
    target  = resource.container.workstation
    timeout = "30s"
  }

  condition "port_recorded" {
    description = "port.txt contains the vault port, and it is inside the random_number range"

    check {
      script          = "scripts/task/find_port/check.sh"
      failure_message = "port.txt must contain only the number in $LAB_VAULT_PORT (between 20000 and 29999)."
    }

    solve {
      script = "scripts/task/find_port/solve.sh"
    }
  }

  condition "port_answers" {
    description = "Something is really listening on that port"

    check {
      script          = "scripts/task/find_port/check_listening.sh"
      failure_message = "The vault did not answer on $LAB_VAULT_PORT. Try: redis-cli -h $LAB_VAULT_HOST -p $LAB_VAULT_PORT ping"
    }
  }
}

resource "task" "unlock_vault" {
  description     = "Authenticate to the vault and store your PIN under the key vault:pin"
  success_message = "Vault unlocked - and you never typed the password on the command line."

  config {
    target  = resource.container.workstation
    timeout = "30s"
  }

  condition "pin_stored" {
    description = "The key vault:pin holds your random_password PIN"

    check {
      script          = "scripts/task/unlock_vault/check.sh"
      failure_message = "GET vault:pin does not return your PIN yet. Authenticate with REDISCLI_AUTH, then SET vault:pin \"$LAB_VAULT_PIN\"."
    }

    solve {
      script = "scripts/task/unlock_vault/solve.sh"
    }
  }
}

resource "task" "register_session" {
  description     = "Create the hash session:<your UUID> in the vault"
  success_message = "Session registered under a key that is globally unique."

  config {
    target  = resource.container.workstation
    timeout = "30s"
  }

  condition "session_hash" {
    description = "session:<uuid> has the fields creature and short with the right values"

    check {
      script          = "scripts/task/register_session/check.sh"
      failure_message = "HGETALL session:$LAB_SESSION_ID must contain creature=$LAB_CREATURE and short=$LAB_SESSION_SHORT."
    }

    solve {
      script = "scripts/task/register_session/solve.sh"
    }
  }

  condition "uuid_version" {
    description = "uuid-version.txt holds the version digit of your UUID"

    check {
      script          = "scripts/task/register_session/check_version.sh"
      failure_message = "Write the UUID version digit (the first character of the third group) to /root/workspace/uuid-version.txt."
    }

    solve {
      script = "scripts/task/register_session/solve_version.sh"
    }
  }
}

resource "task" "tenant_namespace" {
  description     = "Claim tenant:<hex> in the vault and prove the encodings match"
  success_message = "Three encodings, one set of bytes - and a tenant namespace that is yours."

  config {
    target  = resource.container.workstation
    timeout = "30s"
  }

  condition "tenant_key" {
    description = "GET tenant:<hex> returns the decimal form of the same ID"

    check {
      script          = "scripts/task/tenant_namespace/check.sh"
      failure_message = "SET tenant:$LAB_TENANT_HEX to the value of $LAB_TENANT_DEC."
    }

    solve {
      script = "scripts/task/tenant_namespace/solve.sh"
    }
  }

  condition "decoded_matches" {
    description = "tenant-decoded.txt holds the base64 value decoded to hex"

    check {
      script          = "scripts/task/tenant_namespace/check_decoded.sh"
      failure_message = "Decode $LAB_TENANT_B64 to hex and save it to /root/workspace/tenant-decoded.txt - it should equal $LAB_TENANT_HEX."
    }

    solve {
      script = "scripts/task/tenant_namespace/solve_decoded.sh"
    }
  }
}

resource "task" "deploy_shards" {
  description     = "Deploy one shard key per shard and publish a safe manifest"
  success_message = "Mission complete. Five randomizers, one unique, working sandbox."

  config {
    target  = resource.container.workstation
    timeout = "45s"
  }

  condition "shards" {
    description = "Exactly LAB_SHARD_COUNT keys shard:<short>:<n>, each holding your vault host"

    check {
      script          = "scripts/task/deploy_shards/check.sh"
      failure_message = "Create keys shard:$LAB_SESSION_SHORT:1 .. shard:$LAB_SESSION_SHORT:$LAB_SHARD_COUNT (no more, no fewer), each with the value $LAB_VAULT_HOST."
    }

    solve {
      script = "scripts/task/deploy_shards/solve.sh"
    }
  }

  condition "manifest" {
    description = "manifest.env lists your values and does NOT leak the password or PIN"

    check {
      script          = "scripts/task/deploy_shards/check_manifest.sh"
      failure_message = "manifest.env needs VAULT_HOST, VAULT_PORT, SESSION_ID and TENANT_ID lines with your values - and must not contain the password or PIN."
    }

    solve {
      script = "scripts/task/deploy_shards/solve_manifest.sh"
    }
  }
}

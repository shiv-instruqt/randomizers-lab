# Page variables feed Handlebars placeholders in the markdown, so every
# learner reads instructions that contain *their own* random values.
#
# Variable names are camelCase on purpose: the web UI instructions editor has
# been seen escaping underscores inside placeholders, which breaks playback.
# Secrets (password, PIN) are never passed to pages - you fetch them from the
# terminal instead.
#
# `lb` is a literal "{{" so a page can show placeholder syntax without it
# being rendered.

resource "page" "welcome" {
  title = "Mission Briefing"
  file  = "instructions/01-welcome.md"

  variables = {
    creature     = resource.random_creature.mascot.value
    vaultHost    = lower(resource.random_creature.mascot.value)
    vaultPort    = tostring(resource.random_number.vault_port.value)
    shardCount   = tostring(resource.random_number.shard_count.value)
    sessionId    = resource.random_uuid.session.value
    tenantHex    = resource.random_id.tenant.hex
    lb           = "{{"
  }
}

resource "page" "creature" {
  title = "random_creature - Find the Vault"
  file  = "instructions/02-random-creature.md"

  variables = {
    creature  = resource.random_creature.mascot.value
    vaultHost = lower(resource.random_creature.mascot.value)
  }

  activities = {
    creature_badge = resource.task.creature_badge
    creature_quiz  = resource.quiz.creature
  }
}

resource "page" "number" {
  title = "random_number - Knock on the Right Door"
  file  = "instructions/03-random-number.md"

  variables = {
    vaultHost  = lower(resource.random_creature.mascot.value)
    vaultPort  = tostring(resource.random_number.vault_port.value)
    shardCount = tostring(resource.random_number.shard_count.value)
  }

  activities = {
    find_port   = resource.task.find_port
    number_quiz = resource.quiz.number
  }
}

resource "page" "password" {
  title = "random_password - Unlock the Vault"
  file  = "instructions/04-random-password.md"

  variables = {
    vaultHost = lower(resource.random_creature.mascot.value)
    vaultPort = tostring(resource.random_number.vault_port.value)
  }

  activities = {
    unlock_vault  = resource.task.unlock_vault
    password_quiz = resource.quiz.password
  }
}

resource "page" "uuid" {
  title = "random_uuid - Register Your Session"
  file  = "instructions/05-random-uuid.md"

  variables = {
    sessionId    = resource.random_uuid.session.value
    sessionShort = substr(resource.random_uuid.session.value, 0, 8)
  }

  activities = {
    register_session = resource.task.register_session
    uuid_quiz        = resource.quiz.uuid
  }
}

resource "page" "id" {
  title = "random_id - Carve Out a Tenant"
  file  = "instructions/06-random-id.md"

  variables = {
    tenantHex = resource.random_id.tenant.hex
    tenantDec = resource.random_id.tenant.dec
    tenantB64 = resource.random_id.tenant.base64
  }

  activities = {
    tenant_namespace = resource.task.tenant_namespace
    id_quiz          = resource.quiz.id
  }
}

resource "page" "capstone" {
  title = "Capstone - Deploy the Shards"
  file  = "instructions/07-capstone.md"

  variables = {
    creature     = resource.random_creature.mascot.value
    vaultHost    = lower(resource.random_creature.mascot.value)
    vaultPort    = tostring(resource.random_number.vault_port.value)
    shardCount   = tostring(resource.random_number.shard_count.value)
    sessionId    = resource.random_uuid.session.value
    sessionShort = substr(resource.random_uuid.session.value, 0, 8)
    tenantHex    = resource.random_id.tenant.hex
    lb           = "{{"
  }

  activities = {
    deploy_shards = resource.task.deploy_shards
    final_quiz    = resource.quiz.final
  }
}

# Outputs expose non-secret random values for reference and reuse (for
# example when this lab is consumed as a module). The password and PIN are
# deliberately NOT exposed here.

output "creature" {
  value       = resource.random_creature.mascot.value
  description = "random_creature - the vault hostname (before lower())"
}

output "vault_port" {
  value       = resource.random_number.vault_port.value
  description = "random_number - the port the vault listens on"
}

output "session_id" {
  value       = resource.random_uuid.session.value
  description = "random_uuid - the session primary key"
}

output "tenant_hex" {
  value       = resource.random_id.tenant.hex
  description = "random_id - tenant namespace in hex"
}

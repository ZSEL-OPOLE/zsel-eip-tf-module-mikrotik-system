output "identity" {
  description = "Configured system identity (hostname)"
  value       = routeros_system_identity.this.name
}

output "ntp_enabled" {
  description = "NTP client status"
  value       = var.ntp_enabled
}

output "ntp_servers" {
  description = "Configured NTP servers"
  value       = var.ntp_enabled ? var.ntp_servers : []
}

output "dns_enabled" {
  description = "DNS client status"
  value       = var.dns_enabled
}

output "dns_servers" {
  description = "Configured DNS servers"
  value       = var.dns_enabled ? var.dns_servers : []
}

output "dns_allow_remote_requests" {
  description = "DNS server status (allows remote queries)"
  value       = var.dns_enabled ? var.dns_allow_remote_requests : false
}

output "snmp_enabled" {
  description = "SNMP agent status"
  value       = var.snmp_enabled
}

output "snmp_communities" {
  description = "Configured SNMP community names"
  value       = var.snmp_enabled ? keys(var.snmp_communities) : []
  sensitive   = true
}

output "snmp_contact" {
  description = "SNMP sysContact"
  value       = var.snmp_enabled ? var.snmp_contact : null
}

output "snmp_location" {
  description = "SNMP sysLocation"
  value       = var.snmp_enabled ? var.snmp_location : null
}

output "logging_actions" {
  description = "Configured logging action names"
  value       = keys(var.logging_actions)
}

output "logging_rules" {
  description = "Configured logging rule names"
  value       = keys(var.logging_rules)
}

output "timezone" {
  description = "Configured timezone"
  value       = var.timezone
}

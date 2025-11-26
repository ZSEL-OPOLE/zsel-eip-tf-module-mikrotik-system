locals {
  # NTP configuration
  ntp_config = var.ntp_enabled ? {
    enabled = true
    servers = var.ntp_servers
    vrf     = var.ntp_vrf
  } : null
  
  # DNS configuration
  dns_config = var.dns_enabled ? {
    enabled                = true
    servers                = var.dns_servers
    allow_remote_requests  = var.dns_allow_remote_requests
    cache_size             = var.dns_cache_size
    cache_max_ttl          = var.dns_cache_max_ttl
  } : null
  
  # SNMP configuration
  snmp_config = var.snmp_enabled ? {
    enabled     = true
    contact     = var.snmp_contact
    location    = var.snmp_location
    communities = var.snmp_communities
  } : null
  
  # Logging configuration summary
  logging_summary = {
    actions_count = length(var.logging_actions)
    rules_count   = length(var.logging_rules)
    remote_targets = [
      for name, action in var.logging_actions :
      action.remote if action.target == "remote"
    ]
  }
  
  # Module metadata
  module_info = {
    name    = "system"
    version = "1.0.0"
    purpose = "Universal system configuration for MikroTik RouterOS"
  }
}

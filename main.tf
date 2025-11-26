# ===== SYSTEM IDENTITY =====
resource "routeros_system_identity" "this" {
  name = var.identity
}

# ===== NTP CLIENT =====
resource "routeros_system_ntp_client" "this" {
  count = var.ntp_enabled ? 1 : 0
  
  enabled = true
  servers = var.ntp_servers
  vrf     = var.ntp_vrf
}

# ===== DNS CLIENT =====
resource "routeros_ip_dns" "this" {
  count = var.dns_enabled ? 1 : 0
  
  servers                = var.dns_servers
  allow_remote_requests  = var.dns_allow_remote_requests
  cache_size             = var.dns_cache_size
  cache_max_ttl          = var.dns_cache_max_ttl
}

# ===== SNMP AGENT =====
resource "routeros_snmp" "this" {
  count = var.snmp_enabled ? 1 : 0
  
  enabled  = true
  contact  = var.snmp_contact
  location = var.snmp_location
}

resource "routeros_snmp_community" "this" {
  for_each = var.snmp_enabled ? var.snmp_communities : {}
  
  name      = each.key
  addresses = each.value.addresses
  security  = each.value.security
}

# ===== SYSTEM CLOCK =====
resource "routeros_system_clock" "this" {
  count = var.timezone != null ? 1 : 0
  
  time_zone_name = var.timezone
}

# ===== SYSTEM LOGGING ACTIONS =====
resource "routeros_system_logging_action" "this" {
  for_each = var.logging_actions
  
  name   = each.key
  target = each.value.target
  remote = lookup(each.value, "remote", null)
  
  # Note: bsd_syslog structure may differ in terraform-routeros/routeros provider
  # Check provider documentation for correct syntax if needed:
  # https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_logging_action
}

# ===== SYSTEM LOGGING RULES =====
resource "routeros_system_logging" "this" {
  for_each = var.logging_rules
  
  topics = each.value.topics
  action = each.value.action
  prefix = lookup(each.value, "prefix", null)
}

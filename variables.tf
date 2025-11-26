# ===== IDENTITY =====
variable "identity" {
  description = "RouterOS system identity (hostname)"
  type        = string
  
  validation {
    condition     = length(var.identity) >= 1 && length(var.identity) <= 64
    error_message = "Identity must be between 1 and 64 characters."
  }
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]*$", var.identity))
    error_message = "Identity must start with alphanumeric and contain only letters, numbers, dots, hyphens, and underscores."
  }
}

# ===== NTP =====
variable "ntp_enabled" {
  description = "Enable NTP client"
  type        = bool
  default     = true
}

variable "ntp_servers" {
  description = "List of NTP server addresses (IP or FQDN)"
  type        = list(string)
  default     = ["time.cloudflare.com", "time.google.com"]
  
  validation {
    condition     = length(var.ntp_servers) >= 1 && length(var.ntp_servers) <= 8
    error_message = "Provide 1-8 NTP servers for redundancy."
  }
}

variable "ntp_vrf" {
  description = "VRF for NTP client (default: main)"
  type        = string
  default     = "main"
}

# ===== DNS =====
variable "dns_enabled" {
  description = "Enable DNS client"
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "List of DNS server addresses"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
  
  validation {
    condition     = length(var.dns_servers) >= 1 && length(var.dns_servers) <= 8
    error_message = "Provide 1-8 DNS servers."
  }
}

variable "dns_allow_remote_requests" {
  description = "Allow DNS queries from remote hosts (router acts as DNS server)"
  type        = bool
  default     = false
}

variable "dns_cache_size" {
  description = "DNS cache size in KiB (2048-10240)"
  type        = number
  default     = 2048
  
  validation {
    condition     = var.dns_cache_size >= 2048 && var.dns_cache_size <= 10240
    error_message = "DNS cache size must be between 2048 and 10240 KiB."
  }
}

variable "dns_cache_max_ttl" {
  description = "Maximum TTL for DNS cache entries (e.g., '1w' for 1 week)"
  type        = string
  default     = "1w"
}

# ===== SNMP =====
variable "snmp_enabled" {
  description = "Enable SNMP agent"
  type        = bool
  default     = false
}

variable "snmp_communities" {
  description = "SNMP v2c communities configuration"
  type = map(object({
    addresses = list(string)  # Allowed source IPs (0.0.0.0/0 for all)
    security  = string        # "none", "authorized", "private"
  }))
  default = {}
}

variable "snmp_contact" {
  description = "SNMP sysContact (email or name)"
  type        = string
  default     = "admin@example.com"
}

variable "snmp_location" {
  description = "SNMP sysLocation (physical location)"
  type        = string
  default     = "Data Center"
}

# ===== LOGGING =====
variable "logging_actions" {
  description = "Custom logging actions (e.g., remote syslog)"
  type = map(object({
    target     = string                    # "disk", "memory", "remote"
    remote     = optional(string)          # Syslog server IP (if target=remote)
    bsd_syslog = optional(object({
      facility = string                    # "local0" - "local7"
      severity = string                    # "emergency", "alert", "critical", "error", "warning", "notice", "info", "debug"
    }))
  }))
  default = {}
}

variable "logging_rules" {
  description = "Logging rules (topic → action mapping)"
  type = map(object({
    topics = list(string)      # ["info", "error", "warning", "critical", "!debug"]
    action = string            # Action name (e.g., "memory", "remote-graylog")
    prefix = optional(string)  # Optional prefix for log messages
  }))
  default = {}
}

# ===== TIMEZONE =====
variable "timezone" {
  description = "IANA timezone name (e.g., 'Europe/Warsaw', 'UTC')"
  type        = string
  default     = "UTC"
  
  validation {
    condition     = can(regex("^[A-Z][a-zA-Z_/]+$", var.timezone)) || var.timezone == "UTC"
    error_message = "Timezone must be valid IANA timezone (e.g., Europe/Warsaw, America/New_York, UTC)."
  }
}

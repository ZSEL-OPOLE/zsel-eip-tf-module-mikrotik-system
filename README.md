# Terraform MikroTik System Module

Universal system configuration module for MikroTik RouterOS devices (v7.16+).

## Features

- ✅ **System Identity** - Hostname with validation
- ✅ **NTP Client** - Time synchronization (1-8 servers)
- ✅ **DNS Client** - Name resolution + optional DNS server
- ✅ **SNMP v2c** - Monitoring with community-based ACL
- ✅ **System Logging** - Local + remote syslog (BSD format)
- ✅ **Timezone** - IANA timezone configuration

## Usage Examples

### Basic Configuration

```hcl
module "system" {
  source = "./modules/mikrotik/system"
  
  identity = "router-office-01"
  
  ntp_enabled = true
  ntp_servers = ["time.cloudflare.com", "tempus1.gum.gov.pl"]
  
  dns_enabled = true
  dns_servers = ["1.1.1.1", "8.8.8.8"]
  
  timezone = "Europe/Warsaw"
}
```

### Advanced Configuration (Enterprise)

```hcl
module "system" {
  source = "./modules/mikrotik/system"
  
  identity = "ccr-bcu-01"
  
  # NTP Configuration
  ntp_enabled = true
  ntp_servers = [
    "192.168.255.54",           # Local NTP server
    "tempus1.gum.gov.pl",       # Polish government NTP
    "time.cloudflare.com",      # Public fallback
    "time.google.com"           # Public fallback
  ]
  ntp_vrf = "main"
  
  # DNS Configuration (Router as DNS server)
  dns_enabled               = true
  dns_servers               = ["192.168.255.53", "1.1.1.1", "8.8.8.8"]
  dns_allow_remote_requests = true  # LAN clients can use router as DNS
  dns_cache_size            = 4096  # 4 MB cache
  dns_cache_max_ttl         = "1w"  # 1 week max TTL
  
  # SNMP v2c (Zabbix Monitoring)
  snmp_enabled = true
  snmp_communities = {
    "zabbix-monitor" = {
      addresses = ["192.168.255.0/24"]  # Zabbix server subnet
      security  = "authorized"
    }
    "nagios-readonly" = {
      addresses = ["10.10.10.5/32"]
      security  = "authorized"
    }
  }
  snmp_contact  = "network-ops@zsel.opole.pl"
  snmp_location = "CPD B3 Rack 1 U24-U26"
  
  # Remote Syslog (Graylog)
  logging_actions = {
    "remote-graylog" = {
      target = "remote"
      remote = "192.168.255.55"
      bsd_syslog = {
        facility = "local0"
        severity = "info"
      }
    }
    "memory-critical" = {
      target = "memory"
    }
  }
  
  logging_rules = {
    "all-to-graylog" = {
      topics = ["info", "error", "warning", "critical"]
      action = "remote-graylog"
      prefix = "ccr-bcu-01"
    }
    "critical-to-memory" = {
      topics = ["critical", "error"]
      action = "memory-critical"
      prefix = "ALERT"
    }
  }
  
  timezone = "Europe/Warsaw"
}
```

### Multi-Site Configuration

```hcl
# Main Site
module "system_main" {
  source = "./modules/mikrotik/system"
  
  identity    = "router-main-site"
  ntp_servers = ["ntp.main-site.local", "time.cloudflare.com"]
  dns_servers = ["dns.main-site.local", "1.1.1.1"]
  timezone    = "Europe/Warsaw"
  
  snmp_enabled = true
  snmp_communities = {
    "monitoring" = {
      addresses = ["10.0.0.0/8"]
      security  = "authorized"
    }
  }
  snmp_location = "Main Site - Building A"
}

# Branch Office
module "system_branch" {
  source = "./modules/mikrotik/system"
  
  identity    = "router-branch-office"
  ntp_servers = ["ntp.main-site.local", "time.google.com"]
  dns_servers = ["dns.main-site.local", "8.8.8.8"]
  timezone    = "Europe/Warsaw"
  
  snmp_enabled = true
  snmp_communities = {
    "monitoring" = {
      addresses = ["10.0.0.0/8"]
      security  = "authorized"
    }
  }
  snmp_location = "Branch Office - Floor 2"
}
```

### ISP / Service Provider Configuration

```hcl
module "system_isp" {
  source = "./modules/mikrotik/system"
  
  identity = "isp-border-router-01"
  
  # Public NTP servers (no local dependency)
  ntp_servers = [
    "time.cloudflare.com",
    "time.google.com",
    "pool.ntp.org"
  ]
  
  # Public DNS (no recursion)
  dns_enabled               = true
  dns_servers               = ["1.1.1.1", "8.8.8.8"]
  dns_allow_remote_requests = false  # Border router doesn't serve DNS
  
  # SNMP for NOC monitoring
  snmp_enabled = true
  snmp_communities = {
    "noc-readonly" = {
      addresses = ["203.0.113.0/24"]  # NOC subnet
      security  = "authorized"
    }
  }
  snmp_contact  = "noc@isp.example.com"
  snmp_location = "DC1 - Border Router Pod A"
  
  # Remote syslog to SIEM
  logging_actions = {
    "siem-syslog" = {
      target = "remote"
      remote = "siem.isp.example.com"
      bsd_syslog = {
        facility = "local1"
        severity = "info"
      }
    }
  }
  
  logging_rules = {
    "security-events" = {
      topics = ["firewall", "system", "critical"]
      action = "siem-syslog"
      prefix = "BORDER-01"
    }
  }
  
  timezone = "UTC"  # ISP best practice
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| mikrotik | ~> 1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identity | RouterOS system identity (hostname) | `string` | n/a | yes |
| ntp_enabled | Enable NTP client | `bool` | `true` | no |
| ntp_servers | NTP server addresses (1-8 servers) | `list(string)` | `["time.cloudflare.com", "time.google.com"]` | no |
| ntp_vrf | VRF for NTP client | `string` | `"main"` | no |
| dns_enabled | Enable DNS client | `bool` | `true` | no |
| dns_servers | DNS server addresses (1-8 servers) | `list(string)` | `["1.1.1.1", "8.8.8.8"]` | no |
| dns_allow_remote_requests | Allow router to act as DNS server | `bool` | `false` | no |
| dns_cache_size | DNS cache size in KiB (2048-10240) | `number` | `2048` | no |
| dns_cache_max_ttl | Maximum DNS cache TTL | `string` | `"1w"` | no |
| snmp_enabled | Enable SNMP agent | `bool` | `false` | no |
| snmp_communities | SNMP v2c communities with ACL | `map(object)` | `{}` | no |
| snmp_contact | SNMP sysContact | `string` | `"admin@example.com"` | no |
| snmp_location | SNMP sysLocation | `string` | `"Data Center"` | no |
| logging_actions | Custom logging actions | `map(object)` | `{}` | no |
| logging_rules | Logging rules (topic → action) | `map(object)` | `{}` | no |
| timezone | IANA timezone name | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| identity | Configured hostname |
| ntp_enabled | NTP client status |
| ntp_servers | Configured NTP servers |
| dns_enabled | DNS client status |
| dns_servers | Configured DNS servers |
| dns_allow_remote_requests | DNS server mode status |
| snmp_enabled | SNMP agent status |
| snmp_communities | SNMP community names (sensitive) |
| snmp_contact | SNMP sysContact |
| snmp_location | SNMP sysLocation |
| logging_actions | Logging action names |
| logging_rules | Logging rule names |
| timezone | Configured timezone |

## Validation Rules

- **Identity**: 1-64 characters, alphanumeric start, allows dots/hyphens/underscores
- **NTP Servers**: 1-8 servers (redundancy)
- **DNS Servers**: 1-8 servers
- **DNS Cache**: 2048-10240 KiB
- **Timezone**: Valid IANA timezone (e.g., Europe/Warsaw, America/New_York, UTC)

## Notes

- **SNMP v3**: Not supported by provider (use v2c with ACL)
- **NTP VRF**: Use `"main"` for main routing table
- **Syslog Format**: BSD syslog format for remote logging
- **Logging Topics**: Use `!debug` to exclude debug messages

## Testing

```bash
# Validate module
terraform validate

# Plan with example
terraform plan -var="identity=test-router"

# Run tests
terraform test
```

## License

MIT

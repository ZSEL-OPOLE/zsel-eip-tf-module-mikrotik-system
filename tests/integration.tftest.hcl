# =============================================================================
# MikroTik System Module - Integration Tests
# =============================================================================
# Purpose: Test complex scenarios with multiple features enabled
# Expected: All resources should work together without conflicts
# =============================================================================

# Mock provider configuration for testing without real RouterOS device
mock_provider "routeros" {}

# Test 1: Full system configuration (all features enabled)
run "full_system_config" {
  command = plan
  
  variables {
    identity    = "CCR2216-CORE-01"
    ntp_enabled = true
    ntp_servers = ["0.pool.ntp.org", "1.pool.ntp.org", "time.google.com"]
    dns_enabled = true
    dns_servers = ["8.8.8.8", "8.8.4.4", "1.1.1.1"]
    snmp_enabled = true
    snmp_contact = "admin@zsel.edu.pl"
    snmp_location = "ZSEL Opole - Server Room"
    snmp_communities = {
      "public-ro" = {
        authorization = "read"
        addresses     = ["192.168.600.0/24"]
      }
    }
    syslog_servers = ["192.168.10.100"]
    timezone = "Europe/Warsaw"
  }
  
  assert {
    condition     = routeros_system_identity.this.name == "CCR2216-CORE-01"
    error_message = "Identity should be set"
  }
  
  assert {
    condition     = routeros_system_ntp_client.this[0].enabled == true
    error_message = "NTP should be enabled"
  }
  
  assert {
    condition     = length(routeros_system_ntp_client.this[0].servers) == 3
    error_message = "Should have 3 NTP servers"
  }
  
  assert {
    condition     = routeros_ip_dns.this[0].allow_remote_requests == true
    error_message = "DNS should be enabled"
  }
  
  assert {
    condition     = routeros_snmp.this[0].enabled == true
    error_message = "SNMP should be enabled"
  }
  
  assert {
    condition     = routeros_snmp.this[0].contact == "admin@zsel.edu.pl"
    error_message = "SNMP contact should match"
  }
  
  assert {
    condition     = length(routeros_snmp_community.this) == 1
    error_message = "Should have 1 SNMP community"
  }
  
  assert {
    condition     = length(routeros_system_logging_action.this) == 1
    error_message = "Should have 1 logging action"
  }
  
  assert {
    condition     = routeros_system_clock.this.time_zone_name == "Europe/Warsaw"
    error_message = "Timezone should be Europe/Warsaw"
  }
}

# Test 2: Multi-site configuration (multiple NTP/DNS servers)
run "multi_site_config" {
  command = plan
  
  variables {
    identity    = "CRS518-AGG-01"
    ntp_enabled = true
    ntp_servers = [
      "ntp1.site-a.local",
      "ntp2.site-a.local",
      "ntp1.site-b.local",
      "ntp2.site-b.local",
      "0.pool.ntp.org",
      "1.pool.ntp.org"
    ]
    dns_enabled = true
    dns_servers = [
      "192.168.10.1",   # Site A DNS
      "192.168.20.1",   # Site B DNS
      "8.8.8.8",        # Google fallback
      "1.1.1.1"         # Cloudflare fallback
    ]
    timezone = "Europe/Warsaw"
  }
  
  assert {
    condition     = length(routeros_system_ntp_client.this[0].servers) == 6
    error_message = "Should have 6 NTP servers (multi-site + internet)"
  }
  
  assert {
    condition     = length(split(",", routeros_ip_dns.this[0].servers)) == 4
    error_message = "Should have 4 DNS servers"
  }
}

# Test 3: SNMP with multiple communities
run "snmp_multiple_communities" {
  command = plan
  
  variables {
    identity    = "TEST-ROUTER-01"
    snmp_enabled = true
    snmp_contact = "noc@company.com"
    snmp_location = "Datacenter 1"
    snmp_communities = {
      "monitoring-ro" = {
        authorization = "read"
        addresses     = ["192.168.10.0/24"]
      }
      "nagios-ro" = {
        authorization = "read"
        addresses     = ["192.168.10.100"]
      }
      "admin-rw" = {
        authorization = "write"
        addresses     = ["192.168.600.10"]
      }
    }
  }
  
  assert {
    condition     = length(routeros_snmp_community.this) == 3
    error_message = "Should have 3 SNMP communities"
  }
  
  assert {
    condition     = routeros_snmp_community.this["monitoring-ro"].authorization == "read"
    error_message = "monitoring-ro should be read-only"
  }
  
  assert {
    condition     = routeros_snmp_community.this["admin-rw"].authorization == "write"
    error_message = "admin-rw should be read-write"
  }
}

# Test 4: Remote syslog with BSD format
run "remote_syslog_bsd" {
  command = plan
  
  variables {
    identity        = "TEST-ROUTER-01"
    syslog_servers  = ["192.168.10.100", "192.168.10.101"]
    syslog_facility = "local6"
    syslog_bsd      = true
  }
  
  assert {
    condition     = length(routeros_system_logging_action.this) == 2
    error_message = "Should have 2 syslog actions"
  }
  
  assert {
    condition     = routeros_system_logging_action.this["syslog-0"].target == "remote"
    error_message = "Logging target should be remote"
  }
  
  assert {
    condition     = routeros_system_logging_action.this["syslog-0"].bsd_syslog == true
    error_message = "BSD syslog format should be enabled"
  }
}

# Test 5: Outputs validation
run "outputs_validation" {
  command = plan
  
  variables {
    identity    = "OUTPUT-TEST"
    ntp_enabled = true
    ntp_servers = ["pool.ntp.org"]
    dns_enabled = true
    dns_servers = ["8.8.8.8"]
    snmp_enabled = true
    snmp_contact = "test@test.com"
    snmp_communities = {
      "test" = {
        authorization = "read"
        addresses     = ["192.168.1.0/24"]
      }
    }
    syslog_servers  = ["192.168.1.100"]
  }
  
  assert {
    condition     = output.identity == "OUTPUT-TEST"
    error_message = "Output identity should match input"
  }
  
  assert {
    condition     = output.ntp_enabled == true
    error_message = "Output ntp_enabled should be true"
  }
  
  assert {
    condition     = length(output.ntp_servers) == 1
    error_message = "Output should have 1 NTP server"
  }
  
  assert {
    condition     = output.dns_enabled == true
    error_message = "Output dns_enabled should be true"
  }
  
  assert {
    condition     = length(output.dns_servers) == 1
    error_message = "Output should have 1 DNS server"
  }
  
  assert {
    condition     = output.snmp_enabled == true
    error_message = "Output snmp_enabled should be true"
  }
  
  assert {
    condition     = length(output.logging_actions) == 1
    error_message = "Output should have 1 logging action"
  }
}

# Test 6: Edge case - Empty optional values
run "empty_optional_values" {
  command = plan
  
  variables {
    identity    = "EDGE-CASE-01"
    ntp_enabled = false
    dns_enabled = false
    snmp_enabled = false
  }
  
  assert {
    condition     = length(routeros_system_ntp_client.this) == 0
    error_message = "NTP client should not be created when disabled"
  }
  
  assert {
    condition     = length(routeros_ip_dns.this) == 0
    error_message = "DNS should not be created when disabled"
  }
  
  assert {
    condition     = length(routeros_snmp.this) == 0
    error_message = "SNMP should not be created when disabled"
  }
  
  assert {
    condition     = length(routeros_system_logging_action.this) == 0
    error_message = "Logging actions should not be created when disabled"
  }
}


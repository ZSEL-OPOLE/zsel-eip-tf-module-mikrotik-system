# =============================================================================
# MikroTik System Module - Basic Functionality Tests
# =============================================================================
# Purpose: Test basic resource creation with minimal config
# Expected: Resources should be created with default values
# =============================================================================

# Mock provider configuration for testing without real RouterOS device
mock_provider "routeros" {}

# Test 1: Identity resource should be created
run "identity_created" {
  command = plan
  
  variables {
    identity = "TEST-ROUTER-01"
  }
  
  assert {
    condition     = routeros_system_identity.this.name == "TEST-ROUTER-01"
    error_message = "System identity should match input"
  }
}

# Test 2: NTP client disabled by default
run "ntp_disabled_by_default" {
  command = plan
  
  variables {
    identity = "TEST-ROUTER-01"
  }
  
  assert {
    condition     = length(routeros_system_ntp_client.this) == 0
    error_message = "NTP client should be disabled by default"
  }
}

# Test 3: DNS disabled by default
run "dns_disabled_by_default" {
  command = plan
  
  variables {
    identity = "TEST-ROUTER-01"
  }
  
  assert {
    condition     = length(routeros_ip_dns.this) == 0
    error_message = "DNS should be disabled by default"
  }
}

# Test 4: SNMP disabled by default
run "snmp_disabled_by_default" {
  command = plan
  
  variables {
    identity = "TEST-ROUTER-01"
  }
  
  assert {
    condition     = length(routeros_snmp.this) == 0
    error_message = "SNMP should be disabled by default"
  }
}

# Test 5: Logging disabled by default
run "logging_disabled_by_default" {
  command = plan
  
  variables {
    identity = "TEST-ROUTER-01"
  }
  
  assert {
    condition     = length(routeros_system_logging_action.this) == 0
    error_message = "Remote logging should be disabled by default"
  }
}

# Test 6: Enable NTP with single server
run "enable_ntp_single_server" {
  command = plan
  
  variables {
    identity    = "TEST-ROUTER-01"
    ntp_enabled = true
    ntp_servers = ["pool.ntp.org"]
  }
  
  assert {
    condition     = routeros_system_ntp_client.this[0].enabled == true
    error_message = "NTP client should be enabled"
  }
  
  assert {
    condition     = contains(routeros_system_ntp_client.this[0].servers, "pool.ntp.org")
    error_message = "NTP server should be in servers list"
  }
}

# Test 7: Enable DNS with two servers
run "enable_dns_two_servers" {
  command = plan
  
  variables {
    identity    = "TEST-ROUTER-01"
    dns_enabled = true
    dns_servers = ["8.8.8.8", "8.8.4.4"]
  }
  
  assert {
    condition     = routeros_ip_dns.this[0].allow_remote_requests == true
    error_message = "DNS should allow remote requests when enabled"
  }
  
  assert {
    condition     = length(split(",", routeros_ip_dns.this[0].servers)) == 2
    error_message = "Should have 2 DNS servers"
  }
}

# Test 8: System clock with timezone
run "system_clock_timezone" {
  command = plan
  
  variables {
    identity = "TEST-ROUTER-01"
    timezone = "Europe/Warsaw"
  }
  
  assert {
    condition     = routeros_system_clock.this.time_zone_name == "Europe/Warsaw"
    error_message = "Timezone should be set correctly"
  }
}

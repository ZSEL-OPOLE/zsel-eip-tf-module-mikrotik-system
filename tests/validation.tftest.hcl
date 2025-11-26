# =============================================================================
# MikroTik System Module - Validation Tests
# =============================================================================
# Purpose: Test input validation (regex, ranges, enums)
# Expected: All validation rules should fail with invalid inputs
# =============================================================================

# Test 1: Invalid identity (special characters not allowed)
run "invalid_identity_special_chars" {
  command = plan
  
  variables {
    identity = "router-name-with-@-symbol"
  }
  
  expect_failures = [
    var.identity
  ]
}

# Test 2: Invalid NTP servers count (max 8)
run "invalid_ntp_servers_count" {
  command = plan
  
  variables {
    identity = "test-router"
    ntp_servers = [
      "0.pool.ntp.org",
      "1.pool.ntp.org",
      "2.pool.ntp.org",
      "3.pool.ntp.org",
      "time.google.com",
      "time.cloudflare.com",
      "time.apple.com",
      "time.windows.com",
      "time.nist.gov"  # 9th server - should fail
    ]
  }
  
  expect_failures = [
    var.ntp_servers
  ]
}

# Test 3: Invalid DNS servers count (max 8)
run "invalid_dns_servers_count" {
  command = plan
  
  variables {
    identity = "test-router"
    dns_servers = [
      "8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1",
      "9.9.9.9", "208.67.222.222", "208.67.220.220",
      "64.6.64.6", "64.6.65.6"  # 9th server - should fail
    ]
  }
  
  expect_failures = [
    var.dns_servers
  ]
}

# Test 4: Invalid timezone format
run "invalid_timezone_format" {
  command = plan
  
  variables {
    identity = "test-router"
    timezone = "GMT+2"  # Invalid - must be IANA format
  }
  
  expect_failures = [
    var.timezone
  ]
}

# Test 5: Invalid SNMP contact email
run "invalid_snmp_contact_email" {
  command = plan
  
  variables {
    identity = "test-router"
    snmp_enabled = true
    snmp_contact = "invalid-email"  # Missing @ symbol
  }
  
  expect_failures = [
    var.snmp_contact
  ]
}

# Test 6: Valid identity (should pass)
run "valid_identity" {
  command = plan
  
  variables {
    identity = "CCR2216-CORE-01"
  }
  
  assert {
    condition     = var.identity == "CCR2216-CORE-01"
    error_message = "Identity should accept valid router name"
  }
}

# Test 7: Valid NTP servers (maximum 8)
run "valid_ntp_servers_max" {
  command = plan
  
  variables {
    identity = "test-router"
    ntp_servers = [
      "0.pool.ntp.org",
      "1.pool.ntp.org",
      "2.pool.ntp.org",
      "3.pool.ntp.org",
      "time.google.com",
      "time.cloudflare.com",
      "time.apple.com",
      "time.windows.com"
    ]
  }
  
  assert {
    condition     = length(var.ntp_servers) == 8
    error_message = "Should accept exactly 8 NTP servers"
  }
}

# Test 8: Valid timezone (IANA format)
run "valid_timezone_iana" {
  command = plan
  
  variables {
    identity = "test-router"
    timezone = "Europe/Warsaw"
  }
  
  assert {
    condition     = var.timezone == "Europe/Warsaw"
    error_message = "Should accept valid IANA timezone"
  }
}

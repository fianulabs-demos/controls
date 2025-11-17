package rule

# Example OPA/Rego Tests for Control Rules
#
# This file demonstrates how to write comprehensive tests for Rego rules.
# Adapt these patterns to your specific control's logic.
#
# Run with:
#   opa test rule/rule.rego rule_test.rego -v
#
# Learn more: https://www.openpolicyagent.org/docs/latest/policy-testing/

import future.keywords

# ============================================================================
# Test Data Fixtures
# ============================================================================

# Sample occurrence with no vulnerabilities (should pass)
mock_clean_occurrence := {
	"detail": {
		"summary": {
			"critical": 0,
			"high": 0,
			"medium": 0,
			"low": 0,
			"total": 0,
		},
		"vulnerabilities": [],
	},
}

# Sample occurrence with critical vulnerabilities (should fail)
mock_failing_occurrence := {
	"detail": {
		"summary": {
			"critical": 5,
			"high": 10,
			"medium": 20,
			"low": 30,
			"total": 65,
		},
		"vulnerabilities": [
			{
				"level": "critical",
				"identifier": "CVE-2023-1234",
				"description": "SQL Injection",
				"cwe": ["CWE-89"],
				"locations": [{"file": "src/db.js"}],
			},
			{
				"level": "critical",
				"identifier": "CVE-2023-5678",
				"description": "XSS Vulnerability",
				"cwe": ["CWE-79"],
				"locations": [{"file": "src/render.js"}],
			},
		],
	},
}

# Strict policy (zero tolerance)
mock_strict_policy := {
	"required": true,
	"vulnerabilities": {
		"critical": {
			"maximum": 0,
			"exceptions": [],
		},
		"high": {
			"maximum": 0,
			"exceptions": [],
		},
		"medium": {
			"maximum": 5,
			"exceptions": [],
		},
		"low": {
			"maximum": 20,
			"exceptions": [],
		},
	},
	"exclusions": {"locations": []},
}

# Lenient policy (with exceptions)
mock_lenient_policy := {
	"required": true,
	"vulnerabilities": {
		"critical": {
			"maximum": 0,
			"exceptions": ["CWE-79", "CVE-2023-5678"],
		},
		"high": {
			"maximum": 10,
			"exceptions": [],
		},
		"medium": {
			"maximum": 50,
			"exceptions": [],
		},
		"low": {
			"maximum": 100,
			"exceptions": [],
		},
	},
	"exclusions": {"locations": []},
}

# ============================================================================
# Basic Pass/Fail Tests
# ============================================================================

# Test that control passes with clean data and strict policy
test_pass_with_clean_data if {
	pass with input as mock_clean_occurrence
		with data as mock_strict_policy
}

# Test that control fails with vulnerabilities and strict policy
test_fail_with_vulnerabilities if {
	not pass with input as mock_failing_occurrence
		with data as mock_strict_policy
}

# Test that control passes with vulnerabilities but lenient policy
test_pass_with_exceptions if {
	pass with input as mock_failing_occurrence
		with data as mock_lenient_policy
}

# ============================================================================
# Not Required Tests
# ============================================================================

# Test that control is not required when required=false
test_not_required_when_policy_allows if {
	policy := object.union(mock_strict_policy, {"required": false})

	notRequired with input as mock_failing_occurrence
		with data as policy
}

# Test that not required doesn't trigger when passing
test_not_required_false_when_passing if {
	policy := object.union(mock_strict_policy, {"required": false})

	not notRequired with input as mock_clean_occurrence
		with data as policy
}

# ============================================================================
# Exception Handling Tests
# ============================================================================

# Test that CWE exceptions work
test_cwe_exception_excludes_vulnerability if {
	occurrence := {
		"detail": {
			"summary": {"critical": 1},
			"vulnerabilities": [{
				"level": "critical",
				"cwe": ["CWE-79"],
				"identifier": "test-1",
			}],
		},
	}

	policy := {
		"required": true,
		"vulnerabilities": {"critical": {
			"maximum": 0,
			"exceptions": ["CWE-79"],
		}},
		"exclusions": {"locations": []},
	}

	pass with input as occurrence
		with data as policy
}

# Test that CVE exceptions work
test_cve_exception_excludes_vulnerability if {
	occurrence := {
		"detail": {
			"summary": {"critical": 1},
			"vulnerabilities": [{
				"level": "critical",
				"identifier": "CVE-2023-1234",
				"cwe": [],
			}],
		},
	}

	policy := {
		"required": true,
		"vulnerabilities": {"critical": {
			"maximum": 0,
			"exceptions": ["CVE-2023-1234"],
		}},
		"exclusions": {"locations": []},
	}

	pass with input as occurrence
		with data as policy
}

# ============================================================================
# Location Exclusion Tests
# ============================================================================

# Test that location exclusions work
test_location_exclusion_filters_vulnerability if {
	occurrence := {
		"detail": {
			"summary": {"critical": 1},
			"vulnerabilities": [{
				"level": "critical",
				"identifier": "test-1",
				"cwe": [],
				"locations": [{"file": "test/example.js"}],
			}],
		},
	}

	policy := {
		"required": true,
		"vulnerabilities": {"critical": {
			"maximum": 0,
			"exceptions": [],
		}},
		"exclusions": {"locations": ["test/"]},
	}

	pass with input as occurrence
		with data as policy
}

# ============================================================================
# Edge Case Tests
# ============================================================================

# Test with empty vulnerabilities array
test_pass_with_empty_vulnerabilities if {
	occurrence := {"detail": {
		"summary": {"critical": 0},
		"vulnerabilities": [],
	}}

	pass with input as occurrence
		with data as mock_strict_policy
}

# Test with missing detail field
test_handles_missing_detail if {
	occurrence := {}

	# Should not crash (may pass or fail depending on implementation)
	# This test verifies the rule handles missing data gracefully
	result := pass with input as occurrence
		with data as mock_strict_policy

	# Either true or false is ok, just shouldn't crash
	(result == true) or (result == false)
}

# Test with null vulnerabilities
test_handles_null_vulnerabilities if {
	occurrence := {"detail": {
		"summary": {"critical": 0},
		"vulnerabilities": null,
	}}

	# Should not crash
	result := pass with input as occurrence
		with data as mock_strict_policy

	(result == true) or (result == false)
}

# ============================================================================
# Severity Level Tests
# ============================================================================

# Test critical severity threshold
test_critical_threshold_enforced if {
	occurrence := {
		"detail": {
			"summary": {"critical": 1},
			"vulnerabilities": [{
				"level": "critical",
				"identifier": "test-1",
				"cwe": [],
				"locations": [],
			}],
		},
	}

	not pass with input as occurrence
		with data as mock_strict_policy
}

# Test high severity threshold
test_high_threshold_enforced if {
	occurrence := {
		"detail": {
			"summary": {"high": 1},
			"vulnerabilities": [{
				"level": "high",
				"identifier": "test-1",
				"cwe": [],
				"locations": [],
			}],
		},
	}

	not pass with input as occurrence
		with data as mock_strict_policy
}

# Test that medium vulnerabilities pass under threshold
test_medium_under_threshold_passes if {
	occurrence := {
		"detail": {
			"summary": {"medium": 3},
			"vulnerabilities": [
				{
					"level": "medium",
					"identifier": "test-1",
					"cwe": [],
					"locations": [],
				},
				{
					"level": "medium",
					"identifier": "test-2",
					"cwe": [],
					"locations": [],
				},
				{
					"level": "medium",
					"identifier": "test-3",
					"cwe": [],
					"locations": [],
				},
			],
		},
	}

	# Should pass because 3 <= 5 (from mock_strict_policy)
	pass with input as occurrence
		with data as mock_strict_policy
}

# ============================================================================
# Helper Function Tests
# ============================================================================

# Test isLevel helper (if defined in rule)
# Uncomment and adapt if your rule has this helper
# test_is_level_matches_correctly if {
#     isLevel("critical", "critical")
#     not isLevel("critical", "high")
# }

# Test isException helper (if defined in rule)
# Uncomment and adapt if your rule has this helper
# test_is_exception_detects_cwe if {
#     vuln := {
#         "cwe": ["CWE-79"],
#         "identifier": "test-1"
#     }
#     exceptions := ["CWE-79", "CWE-89"]
#
#     isException(vuln, exceptions)
# }

# ============================================================================
# Integration Tests with Real Test Data
# ============================================================================

# Test with actual policy test case file (if available)
# This demonstrates loading real test data
# Uncomment and adapt path as needed
# test_with_real_policy_data if {
#     policy := json.unmarshal(read_file("../../inputs/data/policy_case_1.json"))
#
#     # Test pass scenario
#     pass with input as mock_clean_occurrence
#         with data as policy
# }

# ============================================================================
# Negative Tests (What Should NOT Pass)
# ============================================================================

# Test that exceeding any threshold fails
test_exceeding_critical_fails if {
	occurrence := {"detail": {
		"summary": {"critical": 10},
		"vulnerabilities": [],
	}}

	not pass with input as occurrence
		with data as mock_strict_policy
}

# Test that wrong exception doesn't help
test_wrong_exception_doesnt_help if {
	occurrence := {
		"detail": {
			"summary": {"critical": 1},
			"vulnerabilities": [{
				"level": "critical",
				"identifier": "CVE-9999-9999",
				"cwe": ["CWE-999"],
			}],
		},
	}

	policy := {
		"required": true,
		"vulnerabilities": {"critical": {
			"maximum": 0,
			"exceptions": ["CWE-123"], # Different exception
		}},
		"exclusions": {"locations": []},
	}

	not pass with input as occurrence
		with data as policy
}

# ============================================================================
# Performance Tests (Optional)
# ============================================================================

# Test with large number of vulnerabilities
# test_handles_many_vulnerabilities if {
#     vulnerabilities := [vuln |
#         i := numbers.range(1, 1000)[_]
#         vuln := {
#             "level": "low",
#             "identifier": sprintf("test-%d", [i]),
#             "cwe": [],
#             "locations": []
#         }
#     ]
#
#     occurrence := {
#         "detail": {
#             "summary": {"low": 1000},
#             "vulnerabilities": vulnerabilities
#         }
#     }
#
#     # Should complete quickly even with many vulnerabilities
#     result := pass with input as occurrence
#         with data as mock_lenient_policy
#
#     result == false  # Exceeds threshold
# }

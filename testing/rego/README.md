# Rego Rule Testing with OPA

Comprehensive testing framework for OPA/Rego rules using the OPA CLI.

## Quick Start

```bash
# Install OPA
./install-opa.sh

# Run tests
./run-opa-tests.sh -v
```

## Overview

OPA tests verify your Rego rules:
- ✅ Pass with valid data
- ✅ Fail with policy violations
- ✅ Handle exceptions correctly
- ✅ Handle edge cases gracefully
- ✅ Enforce all thresholds

## Setup

### Install OPA

```bash
# Latest version
./install-opa.sh

# Specific version
./install-opa.sh 0.59.0

# Verify installation
opa version
```

### Copy Test Template

```bash
# Copy example test to your control
cp rule_test.rego ../../rule/
cd ../../rule
```

## Running Tests

### Basic Usage

```bash
# Run all tests
opa test rule.rego rule_test.rego

# Or use helper script
./run-opa-tests.sh
```

### With Options

```bash
# Verbose output
./run-opa-tests.sh -v

# With coverage
./run-opa-tests.sh --coverage

# Target specific directory
./run-opa-tests.sh --target /path/to/rule
```

### Direct OPA Commands

```bash
# Verbose
opa test rule.rego rule_test.rego -v

# Coverage report
opa test --coverage rule.rego rule_test.rego

# Run specific test
opa test -run test_pass_with_clean_data rule.rego rule_test.rego

# Explain test (debug)
opa test -v --explain=full rule.rego rule_test.rego
```

## Writing Tests

### Test Structure

Tests use this pattern:

```rego
test_descriptive_name if {
    # Test passes if this block evaluates to true

    pass with input as mock_occurrence
        with data as mock_policy
}
```

### Example: Test Pass Condition

```rego
test_pass_with_no_vulnerabilities if {
    occurrence := {"detail": {
        "summary": {"critical": 0},
        "vulnerabilities": []
    }}

    policy := {"required": true,
        "vulnerabilities": {"critical": {"maximum": 0}}}

    pass with input as occurrence
        with data as policy
}
```

### Example: Test Fail Condition

```rego
test_fail_with_vulnerabilities if {
    occurrence := {"detail": {
        "summary": {"critical": 5},
        "vulnerabilities": [...]
    }}

    policy := {"required": true,
        "vulnerabilities": {"critical": {"maximum": 0}}}

    # Use 'not' to test that rule fails
    not pass with input as occurrence
        with data as policy
}
```

### Example: Test Exceptions

```rego
test_cwe_exception_works if {
    occurrence := {"detail": {
        "vulnerabilities": [{
            "level": "critical",
            "cwe": ["CWE-79"]
        }]
    }}

    policy := {
        "vulnerabilities": {
            "critical": {
                "maximum": 0,
                "exceptions": ["CWE-79"]  # Should exclude this
            }
        }
    }

    # Should pass because CWE-79 is in exceptions
    pass with input as occurrence
        with data as policy
}
```

## Test Categories

### 1. Basic Pass/Fail Tests

```rego
test_pass_with_clean_data if {
    pass with input as mock_clean_occurrence
        with data as mock_strict_policy
}

test_fail_with_violations if {
    not pass with input as mock_failing_occurrence
        with data as mock_strict_policy
}
```

### 2. Not Required Tests

```rego
test_not_required_when_policy_allows if {
    policy := {"required": false}

    notRequired with input as mock_failing_occurrence
        with data as policy
}
```

### 3. Exception Tests

```rego
test_cwe_exception_excludes_vuln if {
    # Test CWE in exception list
}

test_cve_exception_excludes_vuln if {
    # Test CVE in exception list
}
```

### 4. Threshold Tests

```rego
test_critical_threshold_enforced if {
    # Test exceeding critical threshold fails
}

test_under_threshold_passes if {
    # Test under threshold passes
}
```

### 5. Edge Case Tests

```rego
test_handles_empty_vulnerabilities if {
    # Test with empty array
}

test_handles_missing_fields if {
    # Test with null/missing fields
}
```

## Mock Data Fixtures

Define reusable test data:

```rego
# Clean occurrence (should pass)
mock_clean_occurrence := {
    "detail": {
        "summary": {"critical": 0, "high": 0},
        "vulnerabilities": []
    }
}

# Failing occurrence
mock_failing_occurrence := {
    "detail": {
        "summary": {"critical": 5},
        "vulnerabilities": [...]
    }
}

# Strict policy
mock_strict_policy := {
    "required": true,
    "vulnerabilities": {
        "critical": {"maximum": 0, "exceptions": []}
    }
}
```

## Coverage

### Generate Coverage Report

```bash
# Terminal report
opa test --coverage rule.rego rule_test.rego

# JSON report
opa test --coverage --format=json rule.rego rule_test.rego > coverage.json
```

### Coverage Goals

- **Aim for 80%+ coverage**
- Test all pass/fail conditions
- Test all exception paths
- Test edge cases

### View Untested Code

```bash
# Show which lines aren't covered
opa test --coverage --format=json rule.rego rule_test.rego | jq '.coverage'
```

## Debugging Tests

### Verbose Output

```bash
opa test -v rule.rego rule_test.rego
```

### Explain Mode

```bash
# Show evaluation trace
opa test --explain=full rule.rego rule_test.rego

# Show notes trace
opa test --explain=notes rule.rego rule_test.rego
```

### Add Debug Output in Tests

```rego
test_debug_example if {
    occurrence := {...}

    # Print debug info
    trace(sprintf("Occurrence: %v", [occurrence]))

    result := pass with input as occurrence
        with data as mock_policy

    trace(sprintf("Result: %v", [result]))

    result == true
}
```

## Integration with CI/CD

### GitHub Actions

```yaml
name: Test Rego Rules

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install OPA
        run: |
          curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
          chmod +x opa
          sudo mv opa /usr/local/bin/

      - name: Run OPA tests
        run: |
          cd rule
          opa test -v rule.rego rule_test.rego
```

### GitLab CI/CD

```yaml
test:rego:
  stage: test
  image: openpolicyagent/opa:latest
  script:
    - cd rule
    - opa test -v rule.rego rule_test.rego
```

### Jenkins

```groovy
stage('Test Rego') {
    steps {
        sh './examples/testing/rego/install-opa.sh'
        sh 'cd rule && opa test -v rule.rego rule_test.rego'
    }
}
```

## Best Practices

### DO:

✅ **Test both pass and fail** - Every condition
✅ **Test exceptions** - All exception paths
✅ **Test edge cases** - Empty, null, missing
✅ **Use mock data** - Define reusable fixtures
✅ **Name tests clearly** - Describe what's tested
✅ **Run tests frequently** - Before every commit

### DON'T:

❌ **Skip negative tests** - Test what should NOT pass
❌ **Hardcode test data** - Use mock fixtures
❌ **Test only happy path** - Test failures too
❌ **Ignore coverage** - Aim for 80%+
❌ **Deploy untested rules** - Always test first

## Troubleshooting

### OPA Not Found

```bash
# Install OPA
./install-opa.sh

# Or manually
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod +x opa
sudo mv opa /usr/local/bin/
```

### Test File Not Found

```bash
# Copy template
cp examples/testing/rego/rule_test.rego rule/

# Or create custom test
cd rule
touch rule_test.rego
```

### Tests Fail Unexpectedly

```bash
# Run with verbose to see details
opa test -v rule.rego rule_test.rego

# Use explain mode
opa test --explain=full rule.rego rule_test.rego

# Check test data matches rule expectations
```

## Next Steps

- **[Validation](../validation/)** - File structure validation
- **[Mapper Testing](../mappers/)** - Test Python mappers
- **[Integration Testing](../integration/)** - End-to-end tests
- **[CI/CD Integration](../ci-cd/)** - Add tests to pipeline

---

**Learn more:** [OPA Policy Testing Documentation](https://www.openpolicyagent.org/docs/latest/policy-testing/)

**Need help?** [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

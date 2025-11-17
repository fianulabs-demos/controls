# Control Validation

Comprehensive validation scripts for official controls. Run these before deployment to catch errors early.

## Overview

Validation ensures your control meets all requirements before deployment:
- ✅ Required files exist
- ✅ Syntax is correct (YAML, JSON, Python, Rego)
- ✅ Schema is valid (required fields, format)
- ✅ References are intact (files referenced in contents.json exist)
- ✅ Function signatures match expectations

## Quick Start

```bash
# Validate a single control
./validate-control.sh path/to/my-control

# Validate all controls
./validate-all.sh

# Validate controls matching pattern
./validate-all.sh "snyk.*"
```

## Scripts

### validate-control.sh

Comprehensive validation of a single control directory.

**Usage:**
```bash
./validate-control.sh <control-directory>
```

**Example:**
```bash
cd examples/testing/validation
./validate-control.sh ../../../snyk.sast.vulnerabilities
```

**What It Checks:**

1. **Required Files**
   - `spec.yaml` exists
   - `contents.json` exists
   - `mappers/detail.py` exists
   - `mappers/display.py` exists
   - `rule/rule.rego` exists

2. **File Syntax**
   - YAML files parse correctly
   - JSON files parse correctly
   - Python files compile without errors
   - Policy test cases are valid JSON
   - Occurrence payloads are valid JSON

3. **spec.yaml Schema**
   - Control ID is valid UUID v4
   - Version is string format (not number)
   - Required fields present: path, name, displayKey
   - displayKey is 3-6 uppercase letters
   - Official control flags: isOfficial, evidenceSubmissions, manualAttestations
   - Has measures, relations, assets defined

4. **contents.json References**
   - All referenced files exist
   - Paths resolve correctly
   - Working directories are valid

5. **Python Mapper Signatures**
   - detail.py has `def main(occurrence, context)`
   - display.py has `def main(occurrence, attestation, context)`

6. **Rego Rule Structure**
   - Has `package rule` declaration
   - Defines default states (pass, fail, etc.)
   - Has pass rule implementation

**Exit Codes:**
- `0` - All validations passed
- `1` - One or more validations failed

**Example Output:**
```
==================================================
Validating Control: snyk.sast.vulnerabilities
==================================================

[1] Checking Required Files
✓ Control specification exists: spec.yaml
✓ Contents manifest exists: contents.json
✓ Detail mapper exists: mappers/detail.py
✓ Display mapper exists: mappers/display.py
✓ Rule file exists: rule/rule.rego

[2] Validating File Syntax
✓ spec.yaml has valid YAML syntax
✓ contents.json has valid JSON syntax
✓ detail.py has valid Python syntax
✓ display.py has valid Python syntax

[3] Validating spec.yaml Schema
✓ Control ID has valid UUID format
✓ Version is string format: '1'
✓ Path is present: snyk.sast.vulnerabilities
✓ Name is present: Snyk SAST
✓ Display key format is valid: SNYK
✓ isOfficial is true
✓ evidenceSubmissions is false
✓ manualAttestations is false
✓ Has measures defined
✓ Has relations defined
✓ Has assets defined

[4] Validating contents.json References
✓ Referenced file exists: spec.yaml
✓ Referenced file exists: mappers/detail.py
✓ Referenced file exists: mappers/display.py
✓ Referenced file exists: rule/rule.rego

[5] Validating Python Mapper Signatures
✓ detail.py has correct main() signature
✓ display.py has correct main() signature

[6] Validating Rego Rule Structure
✓ rule.rego has 'package rule' declaration
✓ rule.rego defines 'default pass'
✓ rule.rego defines 'default fail'
✓ rule.rego defines 'pass' rule

==================================================
Validation Summary
==================================================
Passed:   24
Failed:   0
Warnings: 0

✓ All validations passed!
```

---

### validate-all.sh

Batch validation of multiple controls.

**Usage:**
```bash
./validate-all.sh [pattern]
```

**Examples:**
```bash
# Validate all controls
./validate-all.sh

# Validate Snyk controls only
./validate-all.sh "snyk.*"

# Validate CI controls
./validate-all.sh "ci.*"

# Validate testing controls
./validate-all.sh "testing.*"
```

**Features:**
- Runs `validate-control.sh` on each matching control
- Tracks pass/fail counts
- Reports summary at end
- Lists failed controls for easy review

**Exit Codes:**
- `0` - All controls passed
- `1` - One or more controls failed

**Example Output:**
```
==================================================
Batch Control Validation
==================================================

Repository root: /path/to/official-controls
Pattern: *

--------------------------------------------------
Validating: snyk.sast.vulnerabilities
--------------------------------------------------
[... validation output ...]
✓ snyk.sast.vulnerabilities passed validation

--------------------------------------------------
Validating: ci.commit.codereview
--------------------------------------------------
[... validation output ...]
✓ ci.commit.codereview passed validation

==================================================
Batch Validation Summary
==================================================
Total controls validated: 85
Passed: 85
Failed: 0

✓ All controls passed validation!
```

---

## Common Validation Errors

### 1. Missing Required Files

**Error:**
```
✗ Detail mapper missing: mappers/detail.py
```

**Fix:**
```bash
# Create missing file
touch mappers/detail.py

# Add basic structure
cat > mappers/detail.py <<EOF
def main(occurrence, context):
    return {}
EOF
```

---

### 2. Invalid JSON/YAML Syntax

**Error:**
```
✗ spec.yaml has invalid YAML syntax
```

**Fix:**
```bash
# Validate YAML manually
python3 -c "import yaml; yaml.safe_load(open('spec.yaml'))"

# Common issues:
# - Missing quotes on strings with special characters
# - Incorrect indentation
# - Tabs instead of spaces
```

---

### 3. Version Not String Format

**Error:**
```
✗ Version must be string, not number (use 'version: "1"')
```

**Fix:**
```yaml
# Wrong
version: 1

# Correct
version: '1'
```

---

### 4. Invalid UUID Format

**Error:**
```
✗ Control ID has invalid UUID format: 12345
```

**Fix:**
```bash
# Generate new UUID
uuidgen

# Or use online generator
# Copy valid UUID to spec.yaml
```

---

### 5. Invalid Display Key

**Error:**
```
✗ Display key must be 3-6 uppercase letters: snyk-sast
```

**Fix:**
```yaml
# Wrong
displayKey: snyk-sast
displayKey: SNYKSAST  # Too long

# Correct
displayKey: SNYK
displayKey: CKMX
displayKey: WIZ
```

---

### 6. Referenced File Missing

**Error:**
```
✗ Referenced file missing: inputs/data/policy_case_1.json
```

**Fix:**
```bash
# Create missing file
mkdir -p inputs/data
touch inputs/data/policy_case_1.json

# Or remove reference from contents.json if not needed
```

---

### 7. Wrong Python Signature

**Error:**
```
✗ detail.py missing 'def main(occurrence, context)'
```

**Fix:**
```python
# Wrong
def main(occ):
    pass

# Correct
def main(occurrence, context):
    pass
```

---

### 8. Missing Rego Package Declaration

**Error:**
```
✗ rule.rego missing 'package rule' declaration
```

**Fix:**
```rego
# Add at top of rule.rego
package rule

default pass = false

pass if {
    # Your logic
}
```

---

## Using in CI/CD

### GitHub Actions

```yaml
name: Validate Controls

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Make scripts executable
        run: chmod +x examples/testing/validation/*.sh

      - name: Validate all controls
        run: ./examples/testing/validation/validate-all.sh
```

### GitLab CI/CD

```yaml
validate:
  stage: validate
  script:
    - chmod +x examples/testing/validation/*.sh
    - ./examples/testing/validation/validate-all.sh
```

### Jenkins

```groovy
stage('Validate') {
    steps {
        sh 'chmod +x examples/testing/validation/*.sh'
        sh './examples/testing/validation/validate-all.sh'
    }
}
```

---

## Extending Validation

### Add Custom Checks

Edit `validate-control.sh` to add your own validation logic:

```bash
# ============================================================================
# 7. Custom Validation
# ============================================================================

echo -e "${BLUE}[7] Custom Validation${NC}"

# Example: Check for specific policy fields
if [ -f "$CONTROL_DIR/inputs/data/policy_case_1.json" ]; then
    if grep -q "required" "$CONTROL_DIR/inputs/data/policy_case_1.json"; then
        check_pass "Policy has 'required' field"
    else
        check_fail "Policy missing 'required' field"
    fi
fi

echo ""
```

### Integration with Other Tools

```bash
# Add yamllint for stricter YAML validation
if command -v yamllint &> /dev/null; then
    yamllint spec.yaml
fi

# Add OPA for Rego validation
if command -v opa &> /dev/null; then
    opa check rule/rule.rego
fi

# Add pylint for Python style checking
if command -v pylint &> /dev/null; then
    pylint mappers/*.py
fi
```

---

## Best Practices

### 1. Run Validation Frequently

```bash
# Before committing
git add .
./examples/testing/validation/validate-control.sh my-control
git commit -m "Update control"

# Use pre-commit hook
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/bash
./examples/testing/validation/validate-all.sh
EOF
chmod +x .git/hooks/pre-commit
```

### 2. Fix Validation Errors Before Deployment

Never deploy controls with validation errors. They will likely fail at deployment or runtime.

### 3. Add Validation to CI/CD Pipeline

Make validation a required step in your pipeline. Fail the build if validation fails.

### 4. Keep Validation Scripts Updated

As control requirements change, update validation scripts to match new requirements.

---

## Troubleshooting

### Script Permissions

If you get "Permission denied":
```bash
chmod +x validate-control.sh validate-all.sh
```

### Python Not Found

Ensure Python 3 is installed:
```bash
python3 --version

# Or install
# macOS: brew install python3
# Ubuntu: sudo apt install python3
# RHEL: sudo yum install python3
```

### Script Doesn't Find Controls

Check you're running from correct directory:
```bash
# Run from examples/testing/validation/
pwd
# Should show: .../official-controls/examples/testing/validation

# Or use absolute path
./validate-control.sh /path/to/control
```

---

## Next Steps

- **[Mapper Testing](../mappers/)** - Unit test your Python mappers
- **[Rego Testing](../rego/)** - Test your Rego rules
- **[Integration Testing](../integration/)** - End-to-end control testing
- **[CI/CD Integration](../ci-cd/)** - Add validation to your pipeline

---

**Need help?** See [Troubleshooting Guide](../../TROUBLESHOOTING.md) or [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

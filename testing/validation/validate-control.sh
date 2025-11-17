#!/bin/bash
#
# validate-control.sh - Comprehensive control validation script
#
# This script performs extensive validation on a control directory before deployment:
# - File existence checks
# - YAML/JSON syntax validation
# - Schema validation (required fields)
# - Reference integrity (files referenced in contents.json exist)
# - UUID format validation
# - Official control requirements
#
# Usage:
#   ./validate-control.sh <control-directory>
#
# Exit codes:
#   0 - All validations passed
#   1 - One or more validations failed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

# Control directory
CONTROL_DIR="${1:-.}"

if [ ! -d "$CONTROL_DIR" ]; then
    echo -e "${RED}Error: Directory not found: $CONTROL_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}Validating Control: $(basename "$CONTROL_DIR")${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

# ============================================================================
# Helper Functions
# ============================================================================

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

check_file_exists() {
    local file="$1"
    local description="$2"

    if [ -f "$CONTROL_DIR/$file" ]; then
        check_pass "$description exists: $file"
        return 0
    else
        check_fail "$description missing: $file"
        return 1
    fi
}

validate_json() {
    local file="$1"
    local description="$2"

    if python3 -c "import json; json.load(open('$CONTROL_DIR/$file'))" 2>/dev/null; then
        check_pass "$description has valid JSON syntax"
        return 0
    else
        check_fail "$description has invalid JSON syntax"
        return 1
    fi
}

validate_yaml() {
    local file="$1"
    local description="$2"

    if python3 -c "import yaml; yaml.safe_load(open('$CONTROL_DIR/$file'))" 2>/dev/null; then
        check_pass "$description has valid YAML syntax"
        return 0
    else
        check_fail "$description has invalid YAML syntax"
        return 1
    fi
}

validate_python() {
    local file="$1"
    local description="$2"

    if python3 -m py_compile "$CONTROL_DIR/$file" 2>/dev/null; then
        check_pass "$description has valid Python syntax"
        return 0
    else
        check_fail "$description has invalid Python syntax"
        return 1
    fi
}

validate_uuid() {
    local uuid="$1"
    local description="$2"

    # UUID v4 regex pattern
    local uuid_pattern='^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'

    if echo "$uuid" | grep -qiE "$uuid_pattern"; then
        check_pass "$description has valid UUID format"
        return 0
    else
        check_fail "$description has invalid UUID format: $uuid"
        return 1
    fi
}

# ============================================================================
# 1. Required Files Check
# ============================================================================

echo -e "${BLUE}[1] Checking Required Files${NC}"

check_file_exists "spec.yaml" "Control specification"
check_file_exists "contents.json" "Contents manifest"
check_file_exists "mappers/detail.py" "Detail mapper"
check_file_exists "mappers/display.py" "Display mapper"
check_file_exists "rule/rule.rego" "Rule file"

echo ""

# ============================================================================
# 2. File Syntax Validation
# ============================================================================

echo -e "${BLUE}[2] Validating File Syntax${NC}"

if [ -f "$CONTROL_DIR/spec.yaml" ]; then
    validate_yaml "spec.yaml" "spec.yaml"
fi

if [ -f "$CONTROL_DIR/contents.json" ]; then
    validate_json "contents.json" "contents.json"
fi

if [ -f "$CONTROL_DIR/mappers/detail.py" ]; then
    validate_python "mappers/detail.py" "detail.py"
fi

if [ -f "$CONTROL_DIR/mappers/display.py" ]; then
    validate_python "mappers/display.py" "display.py"
fi

# Validate policy test cases
if [ -d "$CONTROL_DIR/inputs/data" ]; then
    for policy in "$CONTROL_DIR/inputs/data"/*.json; do
        if [ -f "$policy" ]; then
            validate_json "${policy#$CONTROL_DIR/}" "$(basename "$policy")"
        fi
    done
fi

# Validate occurrence test cases
if [ -d "$CONTROL_DIR/testing/payloads" ]; then
    for occurrence in "$CONTROL_DIR/testing/payloads"/*.json; do
        if [ -f "$occurrence" ]; then
            validate_json "${occurrence#$CONTROL_DIR/}" "$(basename "$occurrence")"
        fi
    done
fi

echo ""

# ============================================================================
# 3. spec.yaml Schema Validation
# ============================================================================

echo -e "${BLUE}[3] Validating spec.yaml Schema${NC}"

if [ -f "$CONTROL_DIR/spec.yaml" ]; then
    # Extract fields using Python
    SPEC_DATA=$(python3 <<EOF
import yaml
import sys
try:
    with open('$CONTROL_DIR/spec.yaml') as f:
        spec = yaml.safe_load(f)

    # Print fields for shell to capture
    print(f"ID={spec.get('id', '')}")
    print(f"VERSION={spec.get('version', '')}")
    print(f"PATH={spec.get('path', '')}")
    print(f"NAME={spec.get('name', '')}")
    print(f"DISPLAY_KEY={spec.get('displayKey', '')}")
    print(f"IS_OFFICIAL={spec.get('isOfficial', '')}")
    print(f"EVIDENCE_SUBMISSIONS={spec.get('evidenceSubmissions', '')}")
    print(f"MANUAL_ATTESTATIONS={spec.get('manualAttestations', '')}")
    print(f"HAS_MEASURES={len(spec.get('measures', [])) > 0}")
    print(f"HAS_RELATIONS={len(spec.get('relations', [])) > 0}")
    print(f"HAS_ASSETS={len(spec.get('assets', [])) > 0}")
except Exception as e:
    print(f"ERROR={e}", file=sys.stderr)
    sys.exit(1)
EOF
)

    if [ $? -eq 0 ]; then
        eval "$SPEC_DATA"

        # Check required fields
        if [ -n "$ID" ]; then
            validate_uuid "$ID" "Control ID"
        else
            check_fail "Control ID is missing"
        fi

        if [ -n "$VERSION" ]; then
            # Check if version is a string (common mistake: using number instead)
            if python3 -c "import yaml; spec = yaml.safe_load(open('$CONTROL_DIR/spec.yaml')); exit(0 if isinstance(spec.get('version'), str) else 1)" 2>/dev/null; then
                check_pass "Version is string format: '$VERSION'"
            else
                check_fail "Version must be string, not number (use 'version: \"$VERSION\"')"
            fi
        else
            check_fail "Version is missing"
        fi

        if [ -n "$PATH" ]; then
            check_pass "Path is present: $PATH"
        else
            check_fail "Path is missing"
        fi

        if [ -n "$NAME" ]; then
            check_pass "Name is present: $NAME"
        else
            check_fail "Name is missing"
        fi

        if [ -n "$DISPLAY_KEY" ]; then
            # Check if displayKey is 3-6 uppercase letters
            if echo "$DISPLAY_KEY" | grep -qE '^[A-Z]{3,6}$'; then
                check_pass "Display key format is valid: $DISPLAY_KEY"
            else
                check_fail "Display key must be 3-6 uppercase letters: $DISPLAY_KEY"
            fi
        else
            check_fail "Display key is missing"
        fi

        # Check official control flags
        if [ "$IS_OFFICIAL" = "True" ]; then
            check_pass "isOfficial is true"

            if [ "$EVIDENCE_SUBMISSIONS" = "False" ]; then
                check_pass "evidenceSubmissions is false"
            else
                check_fail "evidenceSubmissions must be false for official controls"
            fi

            if [ "$MANUAL_ATTESTATIONS" = "False" ]; then
                check_pass "manualAttestations is false"
            else
                check_fail "manualAttestations must be false for official controls"
            fi
        else
            check_warn "isOfficial is not true (may be custom control)"
        fi

        # Check for measures, relations, assets
        if [ "$HAS_MEASURES" = "True" ]; then
            check_pass "Has measures defined"
        else
            check_fail "No measures defined"
        fi

        if [ "$HAS_RELATIONS" = "True" ]; then
            check_pass "Has relations defined"
        else
            check_fail "No relations defined"
        fi

        if [ "$HAS_ASSETS" = "True" ]; then
            check_pass "Has assets defined"
        else
            check_fail "No assets defined"
        fi
    else
        check_fail "Failed to parse spec.yaml"
    fi
fi

echo ""

# ============================================================================
# 4. contents.json Reference Integrity
# ============================================================================

echo -e "${BLUE}[4] Validating contents.json References${NC}"

if [ -f "$CONTROL_DIR/contents.json" ]; then
    # Extract all file references from contents.json
    REFS=$(python3 <<EOF
import json
try:
    with open('$CONTROL_DIR/contents.json') as f:
        contents = json.load(f)

    refs = []

    # Collect all 'ref' fields
    if 'spec' in contents and 'ref' in contents['spec']:
        refs.append(contents['spec']['ref'])

    if 'detail' in contents and 'ref' in contents['detail']:
        working_dir = contents['detail'].get('workingDirectory', '')
        ref = contents['detail']['ref']
        refs.append(f"{working_dir}/{ref}" if working_dir else ref)

    if 'display' in contents and 'ref' in contents['display']:
        working_dir = contents['display'].get('workingDirectory', '')
        ref = contents['display']['ref']
        refs.append(f"{working_dir}/{ref}" if working_dir else ref)

    if 'rule' in contents and 'ref' in contents['rule']:
        working_dir = contents['rule'].get('workingDirectory', '')
        ref = contents['rule']['ref']
        refs.append(f"{working_dir}/{ref}" if working_dir else ref)

    # Data files
    if 'data' in contents:
        for data in contents['data']:
            if 'ref' in data:
                refs.append(data['ref'])

    # Spec inputs
    if 'spec' in contents and 'inputs' in contents['spec']:
        for inp in contents['spec']['inputs']:
            if 'ref' in inp:
                refs.append(inp['ref'])

    for ref in refs:
        print(ref)
except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)
    sys.exit(1)
EOF
)

    if [ $? -eq 0 ]; then
        while IFS= read -r ref; do
            if [ -n "$ref" ]; then
                if [ -f "$CONTROL_DIR/$ref" ]; then
                    check_pass "Referenced file exists: $ref"
                else
                    check_fail "Referenced file missing: $ref"
                fi
            fi
        done <<< "$REFS"
    else
        check_fail "Failed to parse contents.json references"
    fi
fi

echo ""

# ============================================================================
# 5. Python Mapper Function Signatures
# ============================================================================

echo -e "${BLUE}[5] Validating Python Mapper Signatures${NC}"

# Check detail.py has main(occurrence, context)
if [ -f "$CONTROL_DIR/mappers/detail.py" ]; then
    if grep -q "def main(occurrence, context)" "$CONTROL_DIR/mappers/detail.py"; then
        check_pass "detail.py has correct main() signature"
    else
        check_fail "detail.py missing 'def main(occurrence, context)'"
    fi
fi

# Check display.py has main(occurrence, attestation, context)
if [ -f "$CONTROL_DIR/mappers/display.py" ]; then
    if grep -q "def main(occurrence, attestation, context)" "$CONTROL_DIR/mappers/display.py"; then
        check_pass "display.py has correct main() signature"
    else
        check_fail "display.py missing 'def main(occurrence, attestation, context)'"
    fi
fi

echo ""

# ============================================================================
# 6. Rego Rule Structure
# ============================================================================

echo -e "${BLUE}[6] Validating Rego Rule Structure${NC}"

if [ -f "$CONTROL_DIR/rule/rule.rego" ]; then
    # Check for package declaration
    if grep -q "package rule" "$CONTROL_DIR/rule/rule.rego"; then
        check_pass "rule.rego has 'package rule' declaration"
    else
        check_fail "rule.rego missing 'package rule' declaration"
    fi

    # Check for default declarations
    if grep -q "default pass" "$CONTROL_DIR/rule/rule.rego"; then
        check_pass "rule.rego defines 'default pass'"
    else
        check_fail "rule.rego missing 'default pass' declaration"
    fi

    if grep -q "default fail" "$CONTROL_DIR/rule/rule.rego"; then
        check_pass "rule.rego defines 'default fail'"
    else
        check_warn "rule.rego missing 'default fail' declaration (should define all states)"
    fi

    # Check for pass rule
    if grep -qE "^pass (if|{)" "$CONTROL_DIR/rule/rule.rego"; then
        check_pass "rule.rego defines 'pass' rule"
    else
        check_fail "rule.rego missing 'pass' rule definition"
    fi
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}Passed:${NC}   $CHECKS_PASSED"
echo -e "${RED}Failed:${NC}   $CHECKS_FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ $CHECKS_FAILED validation(s) failed${NC}"
    exit 1
fi

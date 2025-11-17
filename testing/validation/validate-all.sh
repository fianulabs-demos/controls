#!/bin/bash
#
# validate-all.sh - Batch validate multiple controls
#
# This script runs validation on all controls in the repository.
# Useful for CI/CD pipelines to validate all controls before deployment.
#
# Usage:
#   ./validate-all.sh [directory_pattern]
#
# Examples:
#   ./validate-all.sh                 # Validate all controls in parent directory
#   ./validate-all.sh "snyk.*"        # Validate all Snyk controls
#   ./validate-all.sh ci.commit.*     # Validate all CI commit controls
#
# Exit codes:
#   0 - All controls passed validation
#   1 - One or more controls failed validation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pattern for control directories (default: all directories with contents.json)
PATTERN="${1:-*}"

# Counters
TOTAL_CONTROLS=0
PASSED_CONTROLS=0
FAILED_CONTROLS=0

# Array to track failed controls
declare -a FAILED_LIST

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}Batch Control Validation${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

# Find the root of the official-controls repository
# We need to go up from examples/testing/validation to the root
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo -e "${BLUE}Repository root:${NC} $REPO_ROOT"
echo -e "${BLUE}Pattern:${NC} $PATTERN"
echo ""

# Find all directories matching pattern that have contents.json
while IFS= read -r -d '' control_dir; do
    control_name=$(basename "$control_dir")

    # Skip examples directory itself
    if [[ "$control_dir" == *"/examples"* ]]; then
        continue
    fi

    echo -e "${BLUE}--------------------------------------------------${NC}"
    echo -e "${BLUE}Validating: ${NC}$control_name"
    echo -e "${BLUE}--------------------------------------------------${NC}"

    ((TOTAL_CONTROLS++))

    # Run validation script
    if "$SCRIPT_DIR/validate-control.sh" "$control_dir"; then
        ((PASSED_CONTROLS++))
        echo -e "${GREEN}✓ $control_name passed validation${NC}"
    else
        ((FAILED_CONTROLS++))
        FAILED_LIST+=("$control_name")
        echo -e "${RED}✗ $control_name failed validation${NC}"
    fi

    echo ""
done < <(find "$REPO_ROOT" -mindepth 1 -maxdepth 1 -type d -name "$PATTERN" -print0 | sort -z)

# If no controls found, check if pattern is too restrictive
if [ $TOTAL_CONTROLS -eq 0 ]; then
    echo -e "${YELLOW}No controls found matching pattern: $PATTERN${NC}"
    echo ""
    echo "Available controls:"
    find "$REPO_ROOT" -mindepth 1 -maxdepth 1 -type d -name "*" -exec test -f {}/contents.json \; -print | while read -r dir; do
        echo "  - $(basename "$dir")"
    done
    echo ""
    exit 1
fi

# ============================================================================
# Summary
# ============================================================================

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}Batch Validation Summary${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "Total controls validated: $TOTAL_CONTROLS"
echo -e "${GREEN}Passed:${NC} $PASSED_CONTROLS"
echo -e "${RED}Failed:${NC} $FAILED_CONTROLS"
echo ""

if [ $FAILED_CONTROLS -gt 0 ]; then
    echo -e "${RED}Failed controls:${NC}"
    for control in "${FAILED_LIST[@]}"; do
        echo -e "  ${RED}✗${NC} $control"
    done
    echo ""
    echo -e "${RED}Validation failed. Please fix the above controls.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ All controls passed validation!${NC}"
    exit 0
fi

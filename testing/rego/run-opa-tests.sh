#!/bin/bash
#
# run-opa-tests.sh - Run OPA/Rego tests
#
# This script runs OPA tests for Rego rules with various options.
#
# Usage:
#   ./run-opa-tests.sh [options]
#
# Options:
#   -v, --verbose     Verbose output
#   -c, --coverage    Show coverage report
#   -t, --target DIR  Test specific rule directory
#   --help            Show this help

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default options
VERBOSE=""
COVERAGE=""
TARGET_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -c|--coverage)
            COVERAGE="--coverage"
            shift
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose     Verbose output"
            echo "  -c, --coverage    Show coverage report"
            echo "  -t, --target DIR  Test specific rule directory"
            echo "  --help            Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check if OPA is installed
if ! command -v opa &> /dev/null; then
    echo -e "${YELLOW}OPA not found. Installing...${NC}"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "$SCRIPT_DIR/install-opa.sh"
    echo ""
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine control root (three levels up from examples/testing/rego)
CONTROL_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo -e "${BLUE}Running OPA Tests${NC}"
echo -e "${BLUE}=================${NC}"
echo ""

# If target directory specified, use it
if [ -n "$TARGET_DIR" ]; then
    RULE_DIR="$TARGET_DIR"
else
    # Default: test the control's rule directory
    RULE_DIR="$CONTROL_ROOT/rule"
fi

# Check if rule directory exists
if [ ! -d "$RULE_DIR" ]; then
    echo -e "${RED}Error: Rule directory not found: $RULE_DIR${NC}"
    exit 1
fi

# Check if rule.rego exists
if [ ! -f "$RULE_DIR/rule.rego" ]; then
    echo -e "${RED}Error: rule.rego not found in $RULE_DIR${NC}"
    exit 1
fi

# Check if test file exists
TEST_FILE=""
if [ -f "$RULE_DIR/rule_test.rego" ]; then
    TEST_FILE="$RULE_DIR/rule_test.rego"
elif [ -f "$SCRIPT_DIR/rule_test.rego" ]; then
    TEST_FILE="$SCRIPT_DIR/rule_test.rego"
    echo -e "${YELLOW}Using example test file from $SCRIPT_DIR${NC}"
    echo -e "${YELLOW}Copy to your control's rule/ directory for custom tests${NC}"
    echo ""
else
    echo -e "${RED}Error: No test file found${NC}"
    echo "Expected: $RULE_DIR/rule_test.rego"
    echo ""
    echo "Create test file with:"
    echo "  cp $SCRIPT_DIR/rule_test.rego $RULE_DIR/"
    exit 1
fi

echo -e "${BLUE}Rule directory:${NC} $RULE_DIR"
echo -e "${BLUE}Test file:${NC} $TEST_FILE"
echo ""

# Build OPA test command
OPA_CMD="opa test $VERBOSE $COVERAGE $RULE_DIR/rule.rego $TEST_FILE"

echo -e "${BLUE}Running:${NC} $OPA_CMD"
echo ""

# Run tests
if $OPA_CMD; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi

#!/bin/bash
#
# run-tests.sh - Run mapper unit tests with pytest
#
# This script provides convenient options for running mapper tests.
#
# Usage:
#   ./run-tests.sh [options]
#
# Options:
#   -v, --verbose     Verbose output
#   -c, --coverage    Run with coverage report
#   -h, --html        Generate HTML coverage report
#   -f, --fast        Skip slow tests
#   -w, --watch       Watch mode (rerun on file changes)
#   -x, --exitfirst   Exit on first failure
#   -k PATTERN        Run tests matching pattern
#   --help            Show this help

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default options
VERBOSE=""
COVERAGE=""
HTML_REPORT=""
FAST=""
WATCH=""
EXITFIRST=""
PATTERN=""
PYTEST_ARGS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -c|--coverage)
            COVERAGE="--cov=../../mappers --cov-report=term-missing"
            shift
            ;;
        -h|--html)
            HTML_REPORT="--cov-report=html"
            COVERAGE="--cov=../../mappers"
            shift
            ;;
        -f|--fast)
            FAST="-m 'not slow'"
            shift
            ;;
        -w|--watch)
            WATCH="--looponfail"
            shift
            ;;
        -x|--exitfirst)
            EXITFIRST="-x"
            shift
            ;;
        -k)
            PATTERN="-k $2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose     Verbose output"
            echo "  -c, --coverage    Run with coverage report"
            echo "  -h, --html        Generate HTML coverage report"
            echo "  -f, --fast        Skip slow tests"
            echo "  -w, --watch       Watch mode (rerun on file changes)"
            echo "  -x, --exitfirst   Exit on first failure"
            echo "  -k PATTERN        Run tests matching pattern"
            echo "  --help            Show this help"
            exit 0
            ;;
        *)
            PYTEST_ARGS="$PYTEST_ARGS $1"
            shift
            ;;
    esac
done

# Check if pytest is installed
if ! command -v pytest &> /dev/null; then
    echo -e "${YELLOW}pytest not found. Installing dependencies...${NC}"
    pip install -r requirements.txt
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to script directory
cd "$SCRIPT_DIR"

echo -e "${BLUE}Running Mapper Tests${NC}"
echo -e "${BLUE}=====================${NC}"
echo ""

# Build pytest command
PYTEST_CMD="pytest $VERBOSE $COVERAGE $HTML_REPORT $FAST $WATCH $EXITFIRST $PATTERN $PYTEST_ARGS"

echo -e "${BLUE}Command:${NC} $PYTEST_CMD"
echo ""

# Run tests
if $PYTEST_CMD; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"

    # Show coverage report location if HTML was generated
    if [ -n "$HTML_REPORT" ]; then
        echo ""
        echo -e "${BLUE}Coverage report:${NC} file://$SCRIPT_DIR/htmlcov/index.html"
    fi

    exit 0
else
    echo ""
    echo -e "${YELLOW}Some tests failed.${NC}"
    exit 1
fi

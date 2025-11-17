#!/bin/bash

# ============================================================================
# Fianu Controls Deployment Script
# ============================================================================
# This script applies packaged controls (.tgz files) to a Fianu environment
#
# Usage:
#   FIANU_CLIENT_ID=xxx \
#   FIANU_CLIENT_SECRET=xxx \
#   FIANU_HOST=xxx \
#   ./scripts/apply-all.sh [dist_dir]
#
# Arguments:
#   dist_dir    Directory containing .tgz control packages (default: ./dist)
# ============================================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Environment Validation
# ============================================================================

echo ""
echo "============================================================================"
echo "  Fianu Controls Deployment"
echo "============================================================================"
echo ""

echo "Step 1: Validating environment variables..."

VALIDATION_FAILED=0

if [ -z "$FIANU_CLIENT_ID" ]; then
  echo -e "${RED}✗ Error: FIANU_CLIENT_ID environment variable is required${NC}"
  VALIDATION_FAILED=1
else
  echo -e "${GREEN}✓ FIANU_CLIENT_ID is set${NC}"
fi

if [ -z "$FIANU_CLIENT_SECRET" ]; then
  echo -e "${RED}✗ Error: FIANU_CLIENT_SECRET environment variable is required${NC}"
  VALIDATION_FAILED=1
else
  echo -e "${GREEN}✓ FIANU_CLIENT_SECRET is set${NC}"
fi

if [ -z "$FIANU_HOST" ]; then
  echo -e "${RED}✗ Error: FIANU_HOST environment variable is required${NC}"
  VALIDATION_FAILED=1
else
  echo -e "${GREEN}✓ FIANU_HOST is set: ${FIANU_HOST}${NC}"
fi

if [ $VALIDATION_FAILED -eq 1 ]; then
  echo ""
  echo -e "${RED}Environment validation failed. Please set all required variables.${NC}"
  echo ""
  echo "Example usage:"
  echo "  FIANU_CLIENT_ID=your_client_id \\"
  echo "  FIANU_CLIENT_SECRET=your_client_secret \\"
  echo "  FIANU_HOST=https://fianu-dev.fianu.io \\"
  echo "  ./scripts/apply-all.sh"
  echo ""
  exit 1
fi

# ============================================================================
# Directory Validation
# ============================================================================

echo ""
echo "Step 2: Validating package directory..."

DIST_DIR="${1:-./dist}"

if [ ! -d "$DIST_DIR" ]; then
  echo -e "${RED}✗ Error: Directory '$DIST_DIR' does not exist${NC}"
  echo ""
  echo "Please ensure you have packaged controls using:"
  echo "  ./scripts/package-all.sh [control_paths...]"
  echo ""
  exit 1
fi

echo -e "${GREEN}✓ Package directory found: $DIST_DIR${NC}"

# Count .tgz files
TGZ_COUNT=$(find "$DIST_DIR" -maxdepth 1 -name "*.tgz" | wc -l | tr -d ' ')

if [ "$TGZ_COUNT" -eq 0 ]; then
  echo -e "${YELLOW}⚠ Warning: No .tgz files found in $DIST_DIR${NC}"
  echo ""
  echo "Nothing to deploy. Exiting."
  echo ""
  exit 0
fi

echo -e "${BLUE}Found $TGZ_COUNT control package(s) to deploy${NC}"

# ============================================================================
# Deployment
# ============================================================================

echo ""
echo "Step 3: Deploying controls..."
echo ""

DEPLOYED=0
FAILED=0
FAILED_PACKAGES=()

for chart in "$DIST_DIR"/*.tgz; do
  if [ -f "$chart" ]; then
    PACKAGE_NAME=$(basename "$chart")
    echo "----------------------------------------------------------------------------"
    echo -e "${BLUE}Deploying: $PACKAGE_NAME${NC}"
    echo "----------------------------------------------------------------------------"

    # Add a small delay to avoid rate limiting
    if [ $DEPLOYED -gt 0 ]; then
      sleep 2
    fi

    # Run fianu apply and capture exit code
    if fianu apply --path "${chart}" -d; then
      echo -e "${GREEN}✓ Successfully deployed: $PACKAGE_NAME${NC}"
      DEPLOYED=$((DEPLOYED + 1))
    else
      echo -e "${RED}✗ Failed to deploy: $PACKAGE_NAME${NC}"
      FAILED=$((FAILED + 1))
      FAILED_PACKAGES+=("$PACKAGE_NAME")
    fi
    echo ""
  fi
done

# ============================================================================
# Summary
# ============================================================================

echo "============================================================================"
echo "  Deployment Summary"
echo "============================================================================"
echo ""
echo "Environment: $FIANU_HOST"
echo "Total packages: $TGZ_COUNT"
echo -e "${GREEN}Successful: $DEPLOYED${NC}"

if [ $FAILED -gt 0 ]; then
  echo -e "${RED}Failed: $FAILED${NC}"
  echo ""
  echo "Failed packages:"
  for pkg in "${FAILED_PACKAGES[@]}"; do
    echo -e "  ${RED}✗ $pkg${NC}"
  done
  echo ""
  echo -e "${RED}Deployment completed with errors.${NC}"
  exit 1
else
  echo -e "${GREEN}Failed: 0${NC}"
  echo ""
  echo -e "${GREEN}✓ All controls deployed successfully!${NC}"
fi

echo ""
echo "============================================================================"
echo ""
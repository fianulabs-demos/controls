# Getting Started with Fianu Official Controls

This guide will walk you through creating, testing, and deploying your first Fianu Official Control in approximately 30 minutes.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Understanding Controls](#understanding-controls)
3. [Create Your First Control](#create-your-first-control)
4. [Test Locally](#test-locally)
5. [Deploy to Fianu](#deploy-to-fianu)
6. [Next Steps](#next-steps)

---

## Prerequisites

Before you begin, ensure you have:

### 1. Fianu CLI Installed

```bash
# Check if Fianu CLI is installed
fianu --version

# If not installed, follow: https://docs.fianu.io/cli/installation
```

### 2. Fianu Credentials

You'll need:
- **Client ID**: Your Fianu application client ID
- **Client Secret**: Your Fianu application secret
- **Fianu Host**: Your Fianu environment URL (e.g., `https://fianu-dev.fianu.io`)

Set these as environment variables:

```bash
export FIANU_CLIENT_ID="your-client-id"
export FIANU_CLIENT_SECRET="your-client-secret"
export FIANU_HOST="https://fianu-dev.fianu.io"
```

### 3. Basic Tools

- Python 3.8+ installed
- Text editor or IDE
- Terminal/command line access
- Basic understanding of YAML and JSON

---

## Understanding Controls

### What is a Control?

A **Fianu Official Control** is a policy-driven compliance check that evaluates your software development lifecycle. Think of it as a programmable quality gate.

### How Controls Work

```
[Integration Data] → [Transform] → [Evaluate] → [Report]
    (Occurrence)       (Mapper)      (Rule)      (Result)
```

1. **Integration** produces data (e.g., Snyk finds vulnerabilities)
2. **Mapper** transforms data into a structured format
3. **Rule** evaluates data against your policy
4. **Result** reports pass/fail back to Fianu

### Control Components

Every control has 5 essential files:

| File                 | Purpose                       | Language |
|----------------------|-------------------------------|----------|
| `spec.yaml`          | Metadata and policy structure | YAML     |
| `contents.json`      | Component references          | JSON     |
| `mappers/detail.py`  | Data transformation           | Python   |
| `mappers/display.py` | UI formatting                 | Python   |
| `rule/rule.rego`     | Policy evaluation             | Rego     |

Plus test files:
- `inputs/data/policy_*.json` - Sample policy configurations
- `testing/payloads/occ_*.json` - Sample occurrence data

---

## Create Your First Control

We'll create a simple control that checks if a build pipeline completed successfully.

### Step 1: Create Directory Structure

```bash
# Create control directory
mkdir -p my-first-control/{mappers,rule,inputs/data,testing/payloads}

# Navigate into it
cd my-first-control
```

### Step 2: Create spec.yaml

This file defines your control's metadata and policy structure.

```bash
cat > spec.yaml << 'EOF'
id: 00000000-0000-0000-0000-000000000001
displayKey: BUILD
version: '1'
roles: []
path: my.first.control
name: Build Success
fullName: Build Pipeline Success Check
description: Validates that the build pipeline completed successfully

measures:
- name: required
  type: metric
  value: bool
  node_id: 00000000-0000-0000-0000-000000000002
  description: Whether this control is required
  lineItemException:
    enabled: false
    type: null
    expiration:
      required: false
  children: []

results:
  fail: true
  inProgress: false
  notFound: true
  notRequired: true
  pass: true
  warn: false

scope: commit
retries: false

relations:
- isPrimary: false
  collection: 00000000-0000-0000-0000-000000000003
  domain: 00000000-0000-0000-0000-000000000004
  path: ci.build.result
  type: plugin
  note: occurrence
  producer:
    type: plugin
    path: build-system

isOfficial: false
evidenceSubmissions: false
manualAttestations: false

assets:
- type: repository
  cardinality: all
  targetAssetTypeUuid: 681da6ae-edbc-4587-8777-1503602abd4a
  series:
  - name: commit
    code: 2112
EOF
```

**Key fields explained:**
- `id`: Unique identifier (generate with `uuidgen`)
- `path`: Dot-notation name of your control
- `measures`: Policy configuration structure (we just have "required" here)
- `relations`: Where occurrence data comes from
- `results`: Which result states are possible

### Step 3: Create contents.json

This file references all your control components.

```bash
cat > contents.json << 'EOF'
{
  "data": [
    {
      "ref": "inputs/data/policy_case_1.json"
    }
  ],
  "detail": {
    "ref": "detail.py",
    "tests": [],
    "workingDirectory": "mappers"
  },
  "display": {
    "ref": "display.py",
    "tests": [],
    "workingDirectory": "mappers"
  },
  "rule": {
    "engine": "opa",
    "ref": "rule.rego",
    "tests": [],
    "workingDirectory": "rule"
  },
  "spec": {
    "inputs": [
      {
        "ref": "testing/payloads/occ_case_1.json"
      }
    ],
    "ref": "spec.yaml"
  },
  "type": "control",
  "version": "2.0.0"
}
EOF
```

### Step 4: Create detail.py Mapper

This Python script transforms incoming data.

```bash
cat > mappers/detail.py << 'EOF'
def main(occurrence, context):
    """
    Extract build success status from occurrence data.

    Args:
        occurrence: Raw occurrence data from integration
        context: Execution context (tenant, asset info, etc.)

    Returns:
        dict: Structured data with build status
    """
    # Extract the detail section from occurrence
    occ_detail = occurrence.get('detail', {})

    # Get build status (expecting 'success', 'failure', or 'error')
    status = occ_detail.get('status', 'unknown')

    # Return structured data
    return {
        'status': status,
        'passed': status == 'success'
    }
EOF
```

### Step 5: Create display.py Mapper

This formats data for the UI.

```bash
cat > mappers/display.py << 'EOF'
def main(occurrence, attestation, context):
    """
    Format control data for UI display.

    Args:
        occurrence: Occurrence with mapped detail
        attestation: Policy configuration and evaluation results
        context: Execution context

    Returns:
        dict: Display configuration
    """
    detail = occurrence.get('detail', {})
    status = detail.get('status', 'unknown')

    return {
        'description': 'Validates that the build pipeline completed successfully',
        'tag': f'Status: {status.upper()}'
    }
EOF
```

### Step 6: Create rule.rego

This OPA/Rego rule evaluates policy compliance.

```bash
cat > rule/rule.rego << 'EOF'
package rule

# Define default result states
default fail = false
default notFound = false
default notRequired = false
default pass = false

import future.keywords

# Control passes if build was successful
pass if {
    input.detail.passed == true
}

# Control is not required if policy says so
notRequired if {
    not pass
    data.required == false
}
EOF
```

**Rule logic explained:**
- `pass if { input.detail.passed == true }` - Control passes if build succeeded
- `notRequired if { not pass; data.required == false }` - If it fails but policy says it's optional, mark as not required

### Step 7: Create Test Policy

```bash
cat > inputs/data/policy_case_1.json << 'EOF'
{
  "required": true
}
EOF
```

### Step 8: Create Test Occurrence

```bash
cat > testing/payloads/occ_case_1.json << 'EOF'
{
  "spec": {
    "format": "fior",
    "version": "3.0.0"
  },
  "uuid": "00000000-0000-0000-0000-000000000010",
  "path": "ci.build.result",
  "type": "occurrence",
  "status": "complete",
  "timestamp": "2024-01-01T00:00:00Z",
  "asset": {
    "uuid": "00000000-0000-0000-0000-000000000011",
    "name": "my-repo",
    "key": "org/my-repo",
    "type": {
      "category": "software",
      "code": 3000,
      "name": "repository"
    },
    "version": {
      "commit": "abc123"
    }
  },
  "detail": {
    "status": "success",
    "duration": 300,
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
EOF
```

### Step 9: Verify Structure

Your control should now look like this:

```
my-first-control/
├── spec.yaml
├── contents.json
├── mappers/
│   ├── detail.py
│   └── display.py
├── rule/
│   └── rule.rego
├── inputs/
│   └── data/
│       └── policy_case_1.json
└── testing/
    └── payloads/
        └── occ_case_1.json
```

Verify all files exist:

```bash
ls -R
```

---

## Test Locally

Before deploying, validate your control structure:

```bash
# Check that all required files exist
test -f spec.yaml && \
test -f contents.json && \
test -f mappers/detail.py && \
test -f mappers/display.py && \
test -f rule/rule.rego && \
test -f inputs/data/policy_case_1.json && \
test -f testing/payloads/occ_case_1.json && \
echo "✓ All files present" || \
echo "✗ Missing files"
```

### Validate YAML Syntax

```bash
python3 -c "import yaml; yaml.safe_load(open('spec.yaml'))" && \
echo "✓ spec.yaml is valid" || \
echo "✗ spec.yaml has syntax errors"
```

### Validate JSON Syntax

```bash
python3 -c "import json; json.load(open('contents.json'))" && \
echo "✓ contents.json is valid" || \
echo "✗ contents.json has syntax errors"
```

### Test Python Mappers

```bash
# Test detail.py
python3 -c "
import sys
sys.path.insert(0, 'mappers')
import detail
import json

occurrence = json.load(open('testing/payloads/occ_case_1.json'))
result = detail.main(occurrence, {})
print('Detail mapper output:', json.dumps(result, indent=2))
"
```

Expected output:
```json
{
  "status": "success",
  "passed": true
}
```

---

## Deploy to Fianu

### Step 1: Package the Control

```bash
# From the control directory
fianu package --path . -o my-first-control.tgz
```

You should see:
```
✓ Packaged control: my-first-control.tgz
```

### Step 2: Deploy the Control

```bash
fianu apply --path my-first-control.tgz
```

You should see:
```
✓ Successfully applied control: my.first.control
```

### Step 3: Verify Deployment

Log into your Fianu dashboard and navigate to the Controls section. You should see your new control listed!

---

## Next Steps

Congratulations! You've created, tested, and deployed your first Fianu Official Control! 🎉

### Continue Learning

- **[Try the Quickstart](quickstart/)** - Even simpler 5-minute example
- **[Tutorial 1: Hello World](tutorials/01-hello-world/)** - Deeper explanation
- **[Tutorial 2: Vulnerability Scanner](tutorials/02-vulnerability-scanner/)** - More complex control

### Explore More

- **[Templates](templates/)** - Start with pre-built scaffolding
- **[Patterns](patterns/)** - Learn reusable techniques
- **[Recipes](recipes/)** - Integrate with specific tools

### Reference

- **[spec.yaml Reference](reference/schemas/spec.yaml.md)** - Every field explained
- **[Mapper Reference](reference/components/mappers/)** - Python mapper guide
- **[Rule Reference](reference/components/rules/)** - Rego rule guide

### Get Help

- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues
- **[FAQ](faq/)** - Frequently asked questions
- **[GitHub Issues](https://github.com/fianulabs/official-controls/issues)** - Report bugs

---

## Quick Command Reference

```bash
# Package a control
fianu package --path <control-directory> -o <output.tgz>

# Deploy a control
fianu apply --path <control.tgz>

# Set environment variables
export FIANU_CLIENT_ID="your-client-id"
export FIANU_CLIENT_SECRET="your-client-secret"
export FIANU_HOST="https://fianu-dev.fianu.io"

# Generate UUID (for spec.yaml id field)
uuidgen  # macOS/Linux
python3 -c "import uuid; print(uuid.uuid4())"  # Cross-platform
```

---

## Common First-Time Issues

### "Control doesn't appear after deployment"
- Check if control was archived (regenerate ID if so)
- Verify credentials are correct
- Check Fianu host URL is correct

### "Package command fails"
- Ensure `contents.json` exists and is valid JSON
- Verify all referenced files exist
- Check file paths in `contents.json` are relative

### "Rule evaluation fails"
- Verify Rego syntax with `opa eval`
- Check that `input.detail` matches mapper output
- Ensure all default values are defined

**Need more help?** See [Troubleshooting Guide](TROUBLESHOOTING.md)

---

**Ready for more?** → [Continue to Tutorials](tutorials/)

**Want to understand deeper?** → [Read Core Concepts](CONCEPTS.md)

**Have a specific use case?** → [Browse Templates](templates/)

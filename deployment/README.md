# Deployment Guide

Learn how to package and deploy Fianu Official Controls to your environments.

## Overview

Deploying controls involves two steps:
1. **Package**: Bundle control files into a `.tgz` archive
2. **Apply**: Deploy the package to your Fianu environment

## Quick Start

```bash
# Set credentials
export FIANU_CLIENT_ID="your-client-id"
export FIANU_CLIENT_SECRET="your-client-secret"
export FIANU_HOST="https://fianu-dev.fianu.io"

# Package a single control
fianu package --path my-control/ -o my-control.tgz

# Deploy it
fianu apply --path my-control.tgz
```

---

## Table of Contents

1. [Local Development](#local-development)
2. [Packaging Controls](#packaging-controls)
3. [Applying Controls](#applying-controls)
4. [CI/CD Integration](#cicd-integration)
5. [Versioning](#versioning)
6. [Troubleshooting](#troubleshooting)

---

## Local Development

**[Read the full guide →](local-development.md)**

Learn how to:
- Set up your development environment
- Test mappers locally
- Validate Rego rules
- Test complete controls before deployment

**Quick commands**:
```bash
# Test Python mapper
python3 -c "
import sys, json
sys.path.insert(0, 'mappers')
import detail
occ = json.load(open('testing/payloads/occ_case_1.json'))
print(json.dumps(detail.main(occ, {}), indent=2))
"

# Validate Rego rule (requires OPA)
opa eval -d rule/rule.rego "data.rule.pass"

# Validate YAML/JSON
python3 -c "import yaml; yaml.safe_load(open('spec.yaml'))"
python3 -c "import json; json.load(open('contents.json'))"
```

---

## Packaging Controls

**[Read the full guide →](packaging.md)**

### Single Control

```bash
fianu package --path <control-directory> -o <output.tgz>
```

**Example**:
```bash
fianu package --path ./my-snyk-sast -o my-snyk-sast.tgz
```

### Multiple Controls (Official Controls Repo)

If you're working in the official controls repository, you can use the provided scripts:

```bash
# Package specific controls
../scripts/package-all.sh my-control-1 my-control-2

# Package all controls with spec.yaml
../scripts/package-all.sh */
```

### What Gets Packaged

The `fianu package` command includes:
- ✅ `spec.yaml`
- ✅ `contents.json`
- ✅ All files referenced in `contents.json`
- ✅ Test data (if referenced)
- ❌ `.git` directory
- ❌ `__pycache__`
- ❌ `.DS_Store` and other hidden files

---

## Applying Controls

**[Read the full guide →](applying.md)**

### Single Control

```bash
fianu apply --path <control.tgz>
```

**Example**:
```bash
export FIANU_CLIENT_ID="your-client-id"
export FIANU_CLIENT_SECRET="your-client-secret"
export FIANU_HOST="https://fianu-dev.fianu.io"

fianu apply --path my-snyk-sast.tgz
```

### Multiple Controls (Batch Deployment)

If you're working in the official controls repository:

```bash
# Deploy all controls in dist/ directory
../scripts/apply-all.sh dist/
```

The script will:
- ✅ Validate environment variables
- ✅ Find all `.tgz` files
- ✅ Deploy each control with rate limiting
- ✅ Track successes and failures
- ✅ Provide detailed summary

**Environment variables required**:
```bash
export FIANU_CLIENT_ID="your-client-id"
export FIANU_CLIENT_SECRET="your-client-secret"
export FIANU_HOST="https://fianu-dev.fianu.io"
```

### Deployment Output

Successful deployment:
```
✓ Successfully applied control: my.snyk.sast
```

Failed deployment:
```
✗ Failed to apply control: my.snyk.sast
Error: Invalid UUID in spec.yaml
```

---

## CI/CD Integration

Automate control deployment with CI/CD pipelines.

### GitHub Actions

**[Complete guide →](cicd/github-actions.md)**

**Quick setup**:

```yaml
# .github/workflows/deploy-controls.yml
name: Deploy Controls

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Fianu CLI
        uses: fianulabs/actions@main
        with:
          version: ${{ secrets.FIANU_VERSION }}

      - name: Package and Deploy
        env:
          FIANU_CLIENT_ID: ${{ secrets.FIANU_CLIENT_ID }}
          FIANU_CLIENT_SECRET: ${{ secrets.FIANU_CLIENT_SECRET }}
          FIANU_HOST: ${{ secrets.FIANU_HOST }}
        run: |
          fianu package --path ./my-control -o my-control.tgz
          fianu apply --path my-control.tgz
```

**See also**: Reference the [official-controls repository workflows](../../.github/workflows/) for production examples

### GitLab CI

**[Complete guide →](cicd/gitlab-ci.md)**

**Quick setup**:

```yaml
# .gitlab-ci.yml
deploy-controls:
  stage: deploy
  script:
    - export FIANU_CLIENT_ID=$FIANU_CLIENT_ID
    - export FIANU_CLIENT_SECRET=$FIANU_CLIENT_SECRET
    - export FIANU_HOST=$FIANU_HOST
    - fianu package --path ./my-control -o my-control.tgz
    - fianu apply --path my-control.tgz
  only:
    - main
```

### Jenkins

**[Complete guide →](cicd/jenkins.md)**

**Quick setup**:

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        FIANU_CLIENT_ID = credentials('fianu-client-id')
        FIANU_CLIENT_SECRET = credentials('fianu-client-secret')
        FIANU_HOST = 'https://fianu-dev.fianu.io'
    }

    stages {
        stage('Deploy') {
            steps {
                sh 'fianu package --path ./my-control -o my-control.tgz'
                sh 'fianu apply --path my-control.tgz'
            }
        }
    }
}
```

### Custom CI/CD

**[Complete guide →](cicd/custom.md)**

For any CI/CD system:
1. Install Fianu CLI
2. Set environment variables
3. Run package command
4. Run apply command

---

## Versioning

**[Complete guide →](versioning.md)**

### Version Format

```yaml
version: '1'  # String, not number
```

### When to Increment

Increment the version when:
- ✅ Changing policy structure (adding/removing measures)
- ✅ Changing rule logic significantly
- ✅ Breaking changes to mapper output format

Don't increment for:
- ❌ Bug fixes that don't change behavior
- ❌ Display formatting changes
- ❌ Documentation updates
- ❌ Test data changes

### Version Script

If you're in the official controls repository:

```bash
# Bump all control versions
../scripts/bump_versions.py
```

This script:
- Finds all `spec.yaml` files
- Increments version numbers
- Preserves formatting

---

## Best Practices

### DO:
- ✅ Test locally before deploying
- ✅ Use version control (git)
- ✅ Increment versions for breaking changes
- ✅ Deploy to dev/qa before production
- ✅ Keep deployment logs
- ✅ Use CI/CD for automation

### DON'T:
- ❌ Deploy untested controls
- ❌ Skip version increments
- ❌ Deploy directly to production
- ❌ Reuse control IDs
- ❌ Commit credentials to git
- ❌ Deploy without backups

---

## Troubleshooting

### Common Issues

**"Control doesn't appear after deployment"**
- Check if control ID is already archived
- Verify environment (dev vs prod)
- Check permissions

**"Package command fails"**
- Ensure `contents.json` exists
- Verify all referenced files exist
- Check file permissions

**"Apply command fails with auth error"**
- Verify credentials are set correctly
- Check credentials haven't expired
- Ensure correct Fianu host

**More solutions**: [Troubleshooting Guide](../TROUBLESHOOTING.md)

---

## Deployment Checklist

Before deploying:

- [ ] All files present and valid
- [ ] Python mappers tested locally
- [ ] Rego rules tested (if possible)
- [ ] Test data is realistic
- [ ] Version incremented (if needed)
- [ ] Credentials configured
- [ ] Target environment confirmed
- [ ] Backup of previous version (if updating)

---

## Environment Variables

### Required

```bash
FIANU_CLIENT_ID      # Your Fianu client ID
FIANU_CLIENT_SECRET  # Your Fianu client secret
FIANU_HOST           # Target environment URL
```

### Optional

```bash
FIANU_VERSION        # Specific CLI version (for CI/CD)
```

### Setting Variables

**Bash/Zsh**:
```bash
export FIANU_CLIENT_ID="your-id"
export FIANU_CLIENT_SECRET="your-secret"
export FIANU_HOST="https://fianu-dev.fianu.io"
```

**Fish**:
```fish
set -x FIANU_CLIENT_ID "your-id"
set -x FIANU_CLIENT_SECRET "your-secret"
set -x FIANU_HOST "https://fianu-dev.fianu.io"
```

**Windows**:
```cmd
set FIANU_CLIENT_ID=your-id
set FIANU_CLIENT_SECRET=your-secret
set FIANU_HOST=https://fianu-dev.fianu.io
```

---

## Quick Reference

### Commands

```bash
# Package
fianu package --path <dir> -o <file.tgz>

# Apply
fianu apply --path <file.tgz>

# Test locally (Python)
python3 -c "import sys; sys.path.insert(0, 'mappers'); import detail; ..."

# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('spec.yaml'))"

# Validate JSON
python3 -c "import json; json.load(open('contents.json'))"
```

### Scripts (Official Controls Repo)

```bash
# Package multiple
../scripts/package-all.sh control1/ control2/

# Deploy all
../scripts/apply-all.sh dist/

# Bump versions
../scripts/bump_versions.py

# List all controls
../scripts/gather-all-controls.sh
```

---

**Ready to deploy?** → [Local Development Guide](local-development.md)

**Setting up CI/CD?** → [CI/CD Integration](cicd/)

**Need help?** → [Troubleshooting](../TROUBLESHOOTING.md)

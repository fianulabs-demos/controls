# GitHub Actions Deployment Pipelines

Production-ready GitHub Actions workflows for deploying Fianu official controls, based on real working workflows from the official-controls repository.

## Available Workflows

### 1. basic-deployment.yml
**Use for:** Development/testing environments

Simple deployment pattern that:
- Packages specified controls
- Deploys to single environment
- Uses existing custom actions

**Best for:**
- Getting started
- Development workflow
- Single environment

---

### 2. deployment-with-validation.yml ⭐ RECOMMENDED
**Use for:** All environments, especially production

Complete pipeline with:
- ✅ File validation (syntax, schema, structure)
- ✅ Mapper tests (pytest with coverage)
- ✅ Rego tests (OPA)
- ✅ Packaging
- ✅ Deployment

**Best for:**
- Production deployments
- Quality assurance
- Catching errors before deployment

---

### 3. deploy-changed-controls.yml ⚡ SMART
**Use for:** Large repositories with many controls

Intelligent deployment that:
- Detects which controls changed
- Only validates/tests/deploys changed controls
- Much faster than deploying all controls
- Scales to 100+ controls

**Best for:**
- Large control repositories
- Frequent deployments
- Fast feedback cycles

---

### 4. multi-environment.yml 🏭 PRODUCTION
**Use for:** Production environments with multiple stages

Complete promotion workflow:
- DEV → QA → PROD
- Approval gates
- Environment-specific secrets
- Release tagging

**Best for:**
- Production workflows
- Staged rollouts
- Compliance requirements

## Quick Start

### 1. Choose a Workflow

```bash
# Copy to your .github/workflows directory
cp examples/deployment/pipelines/github-actions/deployment-with-validation.yml \
   .github/workflows/deploy.yml
```

### 2. Configure Secrets

Go to GitHub → Settings → Secrets and variables → Actions

Add these secrets:

```
Required:
- FIANU_DEV_CLIENT_ID
- FIANU_DEV_CLIENT_SECRET

Optional:
- FIANU_VERSION (specific CLI version)
- FIANU_QA_CLIENT_ID
- FIANU_QA_CLIENT_SECRET
- PROD_FIANU_CLIENT_ID
- PROD_FIANU_CLIENT_SECRET
```

### 3. Update Control List

Edit the workflow file:

```yaml
env:
  # Replace with your controls (space-separated)
  CONTROLS: "your.control.path another.control"
```

### 4. Commit and Push

```bash
git add .github/workflows/deploy.yml
git commit -m "Add deployment workflow"
git push
```

Watch it run: GitHub → Actions tab

## How These Workflows Work

These workflows use the **existing deployment scripts** from the repository:

### scripts/package-all.sh
Packages controls into .tgz files.

**Usage in workflows:**
```yaml
- name: Package controls
  run: |
    ./scripts/package-all.sh control1 control2 control3
```

**What it does:**
- Creates `dist/` directory
- Packages each control with `fianu package`
- Outputs `.tgz` files to `dist/`

### scripts/apply-all.sh
Deploys packaged controls with rate limiting and error handling.

**Usage in workflows:**
```yaml
- name: Deploy controls
  env:
    FIANU_CLIENT_ID: ${{ secrets.FIANU_CLIENT_ID }}
    FIANU_CLIENT_SECRET: ${{ secrets.FIANU_CLIENT_SECRET }}
    FIANU_HOST: https://fianu-dev.fianu.io
  run: |
    ./scripts/apply-all.sh dist/
```

**What it does:**
- Validates environment variables
- Deploys each `.tgz` file with `fianu apply`
- Rate limits between deployments (2 second delay)
- Tracks success/failure counts
- Returns non-zero exit code if any deployment fails

**Benefits:**
- ✅ Self-contained (no external dependencies)
- ✅ Works in any CI/CD platform
- ✅ Easy to test locally
- ✅ Uses proven, production-tested scripts

## Environment Configuration

### Dev Environment

```yaml
environment:
  name: dev
  url: https://fianu-dev.fianu.io

secrets:
  FIANU_DEV_CLIENT_ID
  FIANU_DEV_CLIENT_SECRET
```

### QA Environment

```yaml
environment:
  name: qa
  url: https://fianu-qa.fianu.io

secrets:
  FIANU_QA_CLIENT_ID
  FIANU_QA_CLIENT_SECRET
```

### Prod Environment

```yaml
environment:
  name: prod
  url: https://app.fianu.io

# Require manual approval
protection_rules:
  required_reviewers: 2
  wait_timer: 5  # minutes

secrets:
  PROD_FIANU_CLIENT_ID
  PROD_FIANU_CLIENT_SECRET
```

## Common Patterns

### Deploy on Push to Main

```yaml
on:
  push:
    branches:
      - main
```

### Deploy on PR + Push

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

### Manual Deployment Only

```yaml
on:
  workflow_dispatch:
```

### Scheduled Deployment

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
```

## Advanced Features

### Matrix Strategy for Multiple Controls

```yaml
strategy:
  matrix:
    control: ${{ fromJson(needs.detect-changes.outputs.changed-controls) }}

steps:
  - name: Validate ${{ matrix.control }}
    run: ./validate.sh ${{ matrix.control }}
```

### Conditional Steps

```yaml
- name: Deploy to prod
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: ...
```

### Artifacts Between Jobs

```yaml
# Upload in job 1
- uses: actions/upload-artifact@v3
  with:
    name: packages
    path: '*.tgz'

# Download in job 2
- uses: actions/download-artifact@v3
  with:
    name: packages
```

### PR Comments

```yaml
- uses: actions/github-script@v6
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: 'Deployment completed!'
      });
```

## Troubleshooting

### Script Not Found

```
Error: ./scripts/package-all.sh: No such file or directory
```

**Solution:** Ensure you're running from repository root where `scripts/` directory exists.

### Secrets Not Found

```
Error: Input required and not supplied: client-id
```

**Solution:** Configure secrets in GitHub repository settings.

### Rate Limit Errors

```
Error: Too many requests
```

**Solution:** Increase `rate-limit-delay` in workflow:

```yaml
with:
  rate-limit-delay: 5  # Increase delay
```

### Workflow Not Triggering

**Check:**
- Branch name matches trigger
- Workflow file is in `.github/workflows/`
- YAML syntax is valid
- Permissions are correct

## Best Practices

### DO:

✅ **Use validation workflow** - Catch errors early
✅ **Set rate limits** - Prevent API overload
✅ **Use environments** - Manage secrets per environment
✅ **Require approvals for prod** - Safety gate
✅ **Test in dev first** - Never skip testing
✅ **Monitor workflow runs** - Check Actions tab regularly

### DON'T:

❌ **Skip validation** - Always validate first
❌ **Remove rate limiting** - Causes API failures
❌ **Hardcode secrets** - Use GitHub secrets
❌ **Deploy to prod automatically** - Require approval
❌ **Ignore failed tests** - Fix before deploying

## Monitoring

### View Workflow Runs

GitHub → Actions → Select workflow → View run

### Check Deployment Status

Look for:
- ✅ Green checkmarks (success)
- ❌ Red X (failure)
- ⏸️ Yellow dot (in progress)

### Download Logs

Actions → Select run → Download logs (top right)

### Set Up Notifications

Settings → Notifications → Actions →Configure alerts

## Migration from Existing Workflows

### From apply_fianulabs_dev.yaml

1. Copy control list
2. Update secrets names
3. Add validation stage
4. Test in dev environment

### From apply_fianulabs_qa.yaml

1. Copy full control list
2. Add test stage before deployment
3. Consider using deploy-changed-controls.yml for speed

### From apply_prod_*.yaml

1. Use multi-environment.yml as base
2. Add approval requirements
3. Add release tagging
4. Configure notifications

## Next Steps

- **[GitLab CI/CD](../gitlab/)** - GitLab pipeline examples
- **[Jenkins](../jenkins/)** - Jenkins pipeline examples
- **[Testing](../../../testing/)** - Validation and testing guides
- **[Troubleshooting](../../../TROUBLESHOOTING.md)** - Common issues

---

**Questions?** [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

# CI/CD Pipeline Examples

Complete CI/CD pipeline examples for deploying Fianu official controls across multiple platforms.

## Available Platforms

| Platform | Best For | Complexity | Documentation |
|----------|----------|------------|---------------|
| **[GitHub Actions](github-actions/)** | GitHub repositories | Medium | ⭐⭐⭐⭐⭐ |
| **[GitLab CI/CD](gitlab/)** | GitLab repositories | Medium | ⭐⭐⭐⭐ |
| **[Jenkins](jenkins/)** | On-premise/any SCM | High | ⭐⭐⭐ |

## Quick Comparison

### GitHub Actions
**Pros:**
- ✅ Native GitHub integration
- ✅ Large marketplace of actions
- ✅ Reusable custom actions
- ✅ Matrix builds
- ✅ Environment protection rules

**Cons:**
- ❌ GitHub-specific
- ❌ Limited free minutes
- ❌ Learning curve for actions

**Best for:** Teams using GitHub, need fast setup

---

### GitLab CI/CD
**Pros:**
- ✅ Built into GitLab
- ✅ Simple YAML syntax
- ✅ Good caching
- ✅ Auto DevOps
- ✅ Integrated container registry

**Cons:**
- ❌ GitLab-specific
- ❌ Less marketplace options
- ❌ Can be resource-intensive

**Best for:** Teams using GitLab, want simplicity

---

### Jenkins
**Pros:**
- ✅ Platform agnostic
- ✅ Massive plugin ecosystem
- ✅ Complete control
- ✅ On-premise option
- ✅ Complex workflows supported

**Cons:**
- ❌ Requires self-hosting
- ❌ Maintenance overhead
- ❌ Steeper learning curve
- ❌ Plugin compatibility issues

**Best for:** Enterprise, on-premise, complex requirements

## Common Pipeline Pattern

All platforms follow this pattern:

```
┌──────────────┐
│   Validate   │  File structure, syntax, schema
└──────┬───────┘
       │
┌──────▼───────┐
│     Test     │  Mapper tests (pytest), Rego tests (OPA)
└──────┬───────┘
       │
┌──────▼───────┐
│   Package    │  Bundle controls into .tgz files
└──────┬───────┘
       │
┌──────▼───────┐
│    Deploy    │  Push to Fianu with rate limiting
└──────────────┘
```

## Pipeline Stages Explained

### 1. Validate Stage

**Purpose:** Catch basic errors before running tests

**What it does:**
- Check required files exist
- Validate YAML/JSON syntax
- Check Python compiles
- Validate spec.yaml schema
- Verify reference integrity

**Tools:** Shell scripts, Python, PyYAML

**Example:**
```bash
./examples/testing/validation/validate-all.sh
```

**Time:** ~30 seconds

---

### 2. Test Stage

**Purpose:** Verify control logic is correct

**What it does:**
- Run mapper unit tests (pytest)
- Run Rego rule tests (OPA)
- Generate coverage reports
- Fail if coverage too low

**Tools:** pytest, OPA, coverage.py

**Example:**
```bash
# Mappers
pytest --cov=mappers --cov-report=term

# Rules
opa test -v rule.rego rule_test.rego
```

**Time:** ~1-2 minutes

---

### 3. Package Stage

**Purpose:** Bundle controls for deployment

**What it does:**
- Package each control into .tgz
- Validate package integrity
- Store as artifacts
- Prepare for deployment

**Tools:** Fianu CLI

**Example:**
```bash
fianu package --path control-name -o control-name.tgz
```

**Time:** ~30 seconds

---

### 4. Deploy Stage

**Purpose:** Push controls to Fianu environment

**What it does:**
- Authenticate with Fianu API
- Deploy each package
- Rate limit between deployments
- Track success/failure
- Report results

**Tools:** Fianu CLI

**Example:**
```bash
fianu apply --path control-name.tgz
```

**Time:** ~2-5 minutes (depends on # of controls)

## Environment Strategy

### Single Environment (Dev)

**Use for:** Development, testing

```yaml
deploy:
  environment: dev
  on: push
```

---

### Multi-Environment (Dev → QA → Prod)

**Use for:** Production deployments

```yaml
deploy-dev:
  environment: dev
  on: push

deploy-qa:
  environment: qa
  needs: deploy-dev
  when: manual

deploy-prod:
  environment: prod
  needs: deploy-qa
  when: manual
  require_approval: true
```

---

### Environment-Per-Branch

**Use for:** Feature branch testing

```yaml
deploy:
  environment: ${{ github.ref_name }}
  on: push
```

## Secrets Management

### Required Secrets

All platforms need these secrets:

```
FIANU_DEV_CLIENT_ID
FIANU_DEV_CLIENT_SECRET
FIANU_HOST (optional, defaults to dev)
```

### Optional Secrets

```
FIANU_QA_CLIENT_ID
FIANU_QA_CLIENT_SECRET
PROD_FIANU_CLIENT_ID
PROD_FIANU_CLIENT_SECRET
FIANU_VERSION (specific CLI version)
```

### Configuration

**GitHub Actions:**
```
Settings → Secrets and variables → Actions
```

**GitLab CI/CD:**
```
Settings → CI/CD → Variables
```

**Jenkins:**
```
Manage Jenkins → Manage Credentials
```

## Rate Limiting

**Why needed:** Fianu API has rate limits

**Default:** 2 seconds between deployments

**Configuration:**

```yaml
# GitHub Actions
rate-limit-delay: 2

# GitLab
sleep 2

# Jenkins
sh 'sleep 2'
```

**Recommendations:**
- Dev: 2 seconds
- QA: 2 seconds
- Prod: 3-5 seconds

## Deployment Strategies

### Deploy All Controls

**Use for:** Initial setup, major changes

**Pros:**
- Ensures full sync
- Simple logic

**Cons:**
- Slow (deploys everything)
- Wastes API calls

**Example:** See `basic-deployment.yml`

---

### Deploy Changed Controls

**Use for:** Regular development

**Pros:**
- Fast (only changed controls)
- Efficient API usage
- Quick feedback

**Cons:**
- More complex logic
- Requires change detection

**Example:** See `deploy-changed-controls.yml`

---

### Deploy On Schedule

**Use for:** Regular syncs

**Pros:**
- Predictable timing
- Off-peak deployments

**Cons:**
- May deploy unchanged controls
- Not responsive to changes

**Example:**
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
```

## Error Handling

### Fail Fast

Stop on first error:

```yaml
fail-on-error: true
```

**Use for:** Development, QA

---

### Continue On Error

Deploy all controls, report failures at end:

```yaml
fail-on-error: false
```

**Use for:** Large deployments

---

### Retry Logic

Retry failed deployments:

```yaml
retry:
  max_attempts: 3
  retry_wait_seconds: 5
```

**Use for:** Network issues

## Notifications

### Slack

```yaml
- name: Notify Slack
  run: |
    curl -X POST $SLACK_WEBHOOK \
      -d '{"text":"Deployment: ${{ job.status }}"}'
```

### Email

```yaml
- name: Send email
  uses: dawidd6/action-send-mail@v3
  with:
    to: team@example.com
    subject: Deployment ${{ job.status }}
```

### GitHub PR Comment

```yaml
- uses: actions/github-script@v6
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        body: 'Deployed successfully!'
      });
```

## Monitoring

### Pipeline Metrics

Track these metrics:
- Deployment success rate
- Average deployment time
- Test pass rate
- Coverage percentage
- Number of controls deployed

### Alerts

Set up alerts for:
- Failed deployments
- Low test coverage
- Slow pipelines
- Rate limit errors

## Best Practices

### DO:

✅ **Always validate first** - Catch errors early
✅ **Test before deploying** - No untested code in prod
✅ **Use rate limiting** - Prevent API overload
✅ **Deploy to dev first** - Test in safe environment
✅ **Require approval for prod** - Safety gate
✅ **Monitor deployments** - Check regularly
✅ **Version your pipelines** - Track changes
✅ **Use secrets management** - Never hardcode credentials

### DON'T:

❌ **Skip validation** - Causes downstream failures
❌ **Deploy without testing** - Recipe for disasters
❌ **Remove rate limiting** - Causes API failures
❌ **Auto-deploy to prod** - Too risky
❌ **Ignore failed deployments** - Fix immediately
❌ **Hardcode secrets** - Security risk
❌ **Run pipelines serially** - Use parallelization

## Troubleshooting

### Pipeline Fails at Validation

**Check:**
- File structure correct?
- YAML syntax valid?
- All required files present?

**Fix:**
```bash
./examples/testing/validation/validate-control.sh my-control
```

---

### Pipeline Fails at Testing

**Check:**
- Tests passing locally?
- Dependencies installed?
- Python/OPA versions match?

**Fix:**
```bash
cd examples/testing/mappers
pytest -v
```

---

### Pipeline Fails at Deployment

**Check:**
- Secrets configured?
- Network connectivity?
- Rate limits hit?
- Package valid?

**Fix:**
- Check secret names
- Increase rate limit delay
- Verify package with `fianu package --validate`

---

### Pipeline Takes Too Long

**Optimize:**
- Use caching
- Run tests in parallel
- Deploy only changed controls
- Use faster runners

---

## Migration Guide

### From Manual Deployment

1. Start with `basic-deployment.yml`
2. Test in dev environment
3. Add validation stage
4. Add testing stage
5. Add QA/prod environments

### From Existing CI/CD

1. Review current pipeline
2. Map stages to new structure
3. Add validation and testing
4. Migrate secrets
5. Test thoroughly before switching

## Next Steps

1. **Choose platform** - GitHub, GitLab, or Jenkins
2. **Copy workflow** - Start with recommended workflow
3. **Configure secrets** - Add credentials
4. **Update control list** - Specify your controls
5. **Test in dev** - Verify it works
6. **Add to production** - Roll out gradually

## Resources

- **[GitHub Actions Examples](github-actions/)** - Complete workflows
- **[GitLab CI/CD Example](gitlab/)** - Pipeline configuration
- **[Jenkins Examples](jenkins/)** - Jenkinsfiles
- **[Testing Framework](../../testing/)** - Validation and testing
- **[Deployment Scripts](../../../scripts/)** - Existing scripts

---

**Questions?** [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

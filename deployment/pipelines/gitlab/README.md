# GitLab CI/CD Pipeline

Complete GitLab CI/CD pipeline for deploying Fianu official controls.

## Quick Start

```bash
# Copy to your repository root
cp .gitlab-ci.yml /path/to/your/repo/

# Configure variables in GitLab:
# Settings → CI/CD → Variables
```

## Configuration

### Required Variables

Go to Project → Settings → CI/CD → Variables

```
FIANU_DEV_CLIENT_ID (masked)
FIANU_DEV_CLIENT_SECRET (masked)
```

### Optional Variables

```
FIANU_QA_CLIENT_ID
FIANU_QA_CLIENT_SECRET
PROD_FIANU_CLIENT_ID
PROD_FIANU_CLIENT_SECRET
FIANU_HOST (default: https://fianu-dev.fianu.io)
```

## Pipeline Stages

1. **Validate** - File structure and schema validation
2. **Test** - Mapper tests (pytest) and Rego tests (OPA)
3. **Package** - Bundle controls into .tgz files
4. **Deploy** - Deploy to environments (dev/qa/prod)

## Usage

### Update Control List

Edit `.gitlab-ci.yml`:

```yaml
variables:
  CONTROLS: "your.control.path another.control.path"
```

### Automatic Deployment

Commits to `main` branch trigger automatic deployment to dev.

### Manual Deployment

QA and Prod deployments require manual trigger:

1. Go to CI/CD → Pipelines
2. Click on pipeline
3. Click "Play" button on deploy:qa or deploy:prod job

## Customization

### Change Python Version

```yaml
variables:
  PYTHON_VERSION: "3.10"
```

### Add Notifications

```yaml
after_script:
  - 'curl -X POST -H "Content-Type: application/json" \
    -d "{\"text\":\"Pipeline $CI_PIPELINE_STATUS\"}" \
    $SLACK_WEBHOOK'
```

## See Also

- [GitHub Actions](../github-actions/) - GitHub workflows
- [Jenkins](../jenkins/) - Jenkins pipelines
- [Testing](../../../testing/) - Testing framework

---

**GitLab Docs:** [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)

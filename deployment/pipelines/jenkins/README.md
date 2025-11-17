# Jenkins Pipelines

Complete Jenkins pipeline examples for deploying Fianu official controls.

## Files

- **Jenkinsfile.declarative** - Declarative pipeline (recommended)
- **Jenkinsfile.scripted** - Scripted pipeline (advanced)

## Quick Start

### 1. Create Pipeline Job

1. Jenkins → New Item
2. Enter name: "Deploy Official Controls"
3. Select "Pipeline"
4. Click OK

### 2. Configure Pipeline

Under "Pipeline" section:
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: your-repo-url
- Script Path: `examples/deployment/pipelines/jenkins/Jenkinsfile.declarative`

### 3. Configure Credentials

Jenkins → Manage Jenkins → Manage Credentials

Add these credentials:
- ID: `fianu-dev-client-id` (Secret text)
- ID: `fianu-dev-client-secret` (Secret text)

### 4. Update Controls List

Edit Jenkinsfile:

```groovy
environment {
    CONTROLS = 'your.control.path another.control'
}
```

### 5. Run Pipeline

Click "Build Now"

## Required Plugins

Install from Jenkins → Manage Plugins:

- ✅ Pipeline
- ✅ Git
- ✅ Credentials Binding
- ✅ Blue Ocean (optional, better UI)
- ✅ HTML Publisher (for coverage reports)

## Pipeline Stages

1. **Checkout** - Clone repository
2. **Validate** - File structure validation
3. **Test** - Run mapper and Rego tests (parallel)
4. **Package** - Create .tgz files
5. **Deploy** - Deploy to Fianu (main branch only)

## Environment Variables

Configure in Jenkinsfile:

```groovy
environment {
    PYTHON_VERSION = '3.11'
    FIANU_HOST = 'https://fianu-dev.fianu.io'
    FIANU_CLIENT_ID = credentials('fianu-dev-client-id')
    FIANU_CLIENT_SECRET = credentials('fianu-dev-client-secret')
}
```

## Triggers

### Poll SCM

```groovy
triggers {
    pollSCM('H/5 * * * *')  // Every 5 minutes
}
```

### GitHub Webhook

1. Install GitHub plugin
2. Configure webhook in GitHub
3. Add trigger:

```groovy
triggers {
    githubPush()
}
```

### Scheduled Build

```groovy
triggers {
    cron('H 2 * * *')  // 2 AM daily
}
```

## Multi-Environment Deployment

```groovy
stage('Deploy') {
    stages {
        stage('Dev') {
            steps {
                // Deploy to dev
            }
        }

        stage('QA') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to QA?"
                ok "Deploy"
            }
            steps {
                // Deploy to QA
            }
        }

        stage('Prod') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to PRODUCTION?"
                ok "Deploy"
                submitter "admin,release-manager"
            }
            steps {
                // Deploy to prod
            }
        }
    }
}
```

## Notifications

### Email

```groovy
post {
    failure {
        emailext subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Check console output at ${env.BUILD_URL}",
                 to: 'team@example.com'
    }
}
```

### Slack

```groovy
post {
    always {
        slackSend channel: '#deployments',
                  color: currentBuild.result == 'SUCCESS' ? 'good' : 'danger',
                  message: "Build ${env.BUILD_NUMBER}: ${currentBuild.result}"
    }
}
```

## Troubleshooting

### Permission Denied on Scripts

```bash
# Add in pipeline
sh 'chmod +x examples/testing/validation/*.sh'
```

### Python Not Found

```bash
# Use Python 3 explicitly
sh 'python3 --version'
sh 'pip3 install -r requirements.txt'
```

### OPA Not Found

```bash
# Install in pipeline
sh '''
    curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
    chmod +x opa
    sudo mv opa /usr/local/bin/
'''
```

## Best Practices

✅ Use declarative pipeline (easier to maintain)
✅ Parallel test stages for speed
✅ Archive artifacts
✅ Publish test reports
✅ Require approval for prod
✅ Send notifications on failure

## See Also

- [GitHub Actions](../github-actions/) - GitHub workflows
- [GitLab CI/CD](../gitlab/) - GitLab pipelines
- [Testing](../../../testing/) - Testing framework

---

**Jenkins Docs:** [Pipeline](https://www.jenkins.io/doc/book/pipeline/)

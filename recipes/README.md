# Control Recipes

Cookbook-style solutions for integrating Fianu controls with specific tools and platforms. Each recipe provides a complete, copy-paste ready implementation.

## Recipe Index

### 🔒 Vulnerability Scanning

| Tool | Recipe | Status |
|------|--------|--------|
| Snyk SAST | [snyk-sast.md](vulnerability-scanning/snyk-sast.md) | 🚧 Coming soon |
| Checkmarx | [checkmarx.md](vulnerability-scanning/checkmarx.md) | 🚧 Coming soon |
| Wiz Containers | [wiz-containers.md](vulnerability-scanning/wiz-containers.md) | 🚧 Coming soon |
| GitLab SAST | [gitlab-sast.md](vulnerability-scanning/gitlab-sast.md) | 🚧 Coming soon |
| Generic SARIF | [generic-sarif.md](vulnerability-scanning/generic-sarif.md) | 🚧 Coming soon |

### 🧪 Test Results

| Tool | Recipe | Status |
|------|--------|--------|
| JUnit | [junit.md](test-results/junit.md) | 🚧 Coming soon |
| Pytest | [pytest.md](test-results/pytest.md) | 🚧 Coming soon |
| Custom Format | [custom-test-format.md](test-results/custom-test-format.md) | 🚧 Coming soon |

### 🔗 Code Review

| Tool | Recipe | Status |
|------|--------|--------|
| Jira PR Association | [jira-pr-association.md](code-review/jira-pr-association.md) | 🚧 Coming soon |
| GitHub Code Review | [github-code-review.md](code-review/github-code-review.md) | 🚧 Coming soon |
| GitLab Merge Requests | [gitlab-merge-requests.md](code-review/gitlab-merge-requests.md) | 🚧 Coming soon |

### 📊 Coverage

| Tool | Recipe | Status |
|------|--------|--------|
| Cobertura | [cobertura.md](coverage/cobertura.md) | 🚧 Coming soon |
| JaCoCo | [jacoco.md](coverage/jacoco.md) | 🚧 Coming soon |
| Custom Coverage | [custom-coverage.md](coverage/custom-coverage.md) | 🚧 Coming soon |

### 📋 Compliance

| Tool | Recipe | Status |
|------|--------|--------|
| SBOM Validation | [sbom-validation.md](compliance/sbom-validation.md) | 🚧 Coming soon |
| License Scanning | [license-scanning.md](compliance/license-scanning.md) | 🚧 Coming soon |
| Signature Verification | [signature-verification.md](compliance/signature-verification.md) | 🚧 Coming soon |

### 🎨 Custom

| Type | Recipe | Status |
|------|--------|--------|
| Custom API Integration | [custom-api-integration.md](custom/custom-api-integration.md) | 🚧 Coming soon |
| Multi-Source Aggregation | [multi-source-aggregation.md](custom/multi-source-aggregation.md) | 🚧 Coming soon |
| Complex Policy Logic | [complex-policy-logic.md](custom/complex-policy-logic.md) | 🚧 Coming soon |

---

## How to Use Recipes

### 1. Find Your Tool
Browse the index above or use the category links to find your specific integration.

### 2. Follow the Recipe
Each recipe provides:
- **Problem Statement**: What you're trying to achieve
- **Prerequisites**: What you need before starting
- **Step-by-Step Instructions**: Complete walkthrough
- **Complete Code**: Copy-paste ready implementation
- **Test Data**: Realistic examples
- **Deployment**: How to package and deploy
- **Troubleshooting**: Common issues and solutions

### 3. Customize
Recipes are designed to work out-of-the-box, but you can customize:
- Policy thresholds
- Exception lists
- Display formatting
- Additional validation logic

---

## Recipe Format

Every recipe follows this structure:

```markdown
# Tool Name Integration

## Overview
Brief description of what this control does

## Prerequisites
- Tool version requirements
- Fianu CLI setup
- Required permissions

## Problem
What compliance requirement this solves

## Solution
How the control works

## Implementation

### Step 1: Create Control Structure
Commands to set up directories

### Step 2: Configure spec.yaml
Complete spec.yaml with explanations

### Step 3: Implement Mappers
Complete Python code with comments

### Step 4: Implement Rule
Complete Rego code with comments

### Step 5: Add Test Data
Sample occurrence and policy data

### Step 6: Test Locally
How to validate before deploying

### Step 7: Deploy
Package and apply commands

## Testing
How to test with real data

## Troubleshooting
Common issues and solutions

## Variations
Alternative implementations

## Further Reading
Related patterns, templates, examples
```

---

## Quick Start Example

```bash
# 1. Find your recipe
cd recipes/vulnerability-scanning

# 2. Read the recipe
cat snyk-sast.md

# 3. Create control
mkdir my-snyk-sast
cd my-snyk-sast

# 4. Copy code from recipe
# (Use the provided code blocks)

# 5. Test
fianu package --path . -o my-snyk-sast.tgz

# 6. Deploy
fianu apply --path my-snyk-sast.tgz
```

---

## Recipe Categories

### By Complexity

**Beginner** (Simple integration):
- Boolean checks
- Single status validation
- Basic threshold checks

**Intermediate** (Moderate complexity):
- Multi-level thresholds
- Exception handling
- Summary aggregation

**Advanced** (Complex logic):
- Multi-source aggregation
- Complex policy rules
- Custom data formats

### By Data Format

**Standard Formats**:
- SARIF (security scans)
- JUnit (test results)
- Cobertura (coverage)

**Custom Formats**:
- Tool-specific JSON
- XML formats
- API responses

---

## Common Patterns in Recipes

Most recipes use these patterns:

1. **Severity-Based Evaluation** (vulnerability scanning)
2. **Threshold Checking** (test results, coverage)
3. **Association Validation** (code review)
4. **Exception Handling** (almost all controls)
5. **SARIF Parsing** (security tools)
6. **Summary Aggregation** (large datasets)

See **[Patterns](../patterns/)** for detailed explanations of each.

---

## Contribution Guidelines

Have a recipe to share?

**We especially need**:
- Popular tool integrations
- Custom format parsers
- Real-world use cases
- Troubleshooting tips

See **[Contributing Guide](../contributing/)** for submission process.

---

## Getting Help

### Recipe-Specific Help
- Read the Troubleshooting section in each recipe
- Check Common Issues at the end of each recipe
- Look for "Known Limitations" sections

### General Help
- **[Templates](../templates/)** - Pre-built scaffolding
- **[Patterns](../patterns/)** - Reusable techniques
- **[Examples](../examples/)** - Complete working controls
- **[Troubleshooting](../TROUBLESHOOTING.md)** - Common issues
- **[GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)** - Community support

### Can't Find Your Tool?
1. Check if there's a similar tool recipe you can adapt
2. Start with the closest [Template](../templates/)
3. Use relevant [Patterns](../patterns/)
4. Ask in [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

---

## Recipe vs Template vs Pattern

| | Recipe | Template | Pattern |
|---|---|---|---|
| **What** | Tool-specific solution | Generic control type | Reusable technique |
| **Scope** | Complete integration | Control structure | Single problem |
| **Detail Level** | Step-by-step | Annotated scaffold | Code snippet |
| **Use When** | Integrating specific tool | Starting any control | Need specific technique |
| **Example** | "How to integrate Snyk" | "Vulnerability scanner control" | "Exception handling" |

**Which to use?**
- **Recipe**: You know exactly what tool you're integrating
- **Template**: You know the control type but not the specific tool
- **Pattern**: You need a specific technique for part of your control

---

## Learning Path

1. **Find your tool** in the recipe index
2. **Follow the recipe** exactly first time
3. **Understand the patterns** used
4. **Customize** for your specific needs
5. **Share** your variations with the community

---

**Need to integrate a specific tool?** → Browse recipes above

**Don't see your tool?** → Start with [Templates](../templates/)

**Need a technique?** → Check [Patterns](../patterns/)

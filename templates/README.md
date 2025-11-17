# Control Templates

Pre-built, production-ready templates you can copy, customize, and deploy. Each template includes comprehensive inline documentation and multiple configuration examples.

## Available Templates

### 🔒 [vulnerability-scanner/](vulnerability-scanner/)
**For**: SAST, DAST, SCA, container scanning

**Handles**: Severity-based evaluation (critical/high/medium/low), exceptions, location exclusions

**Use when**: Evaluating security scan results from tools like Snyk, Checkmarx, Wiz, GitLab SAST, etc.

**Features**:
- ✅ Multi-level severity thresholds
- ✅ CWE/CVE exception handling
- ✅ File path exclusions
- ✅ SARIF format parsing
- ✅ Summary aggregation

**Status**: ✅ Complete

---

### 🧪 [test-results/](test-results/)
**For**: Unit tests, functional tests, integration tests

**Handles**: Test status evaluation (passed/failed/error/skipped), count thresholds, test class exceptions

**Use when**: Validating JUnit, Pytest, or custom test framework results

**Features**:
- ✅ Status-based thresholds (max failed, max error, max skipped)
- ✅ Minimum total tests requirement
- ✅ Test class/name exceptions
- ✅ Multiple test format support

**Status**: 🚧 Coming soon

---

### 🔗 [association-validator/](association-validator/)
**For**: Jira, GitHub, GitLab PR/MR validation

**Handles**: Association data extraction, multi-field validation, issue type/status checks

**Use when**: Enforcing ticket association on pull requests or merge requests

**Features**:
- ✅ Issue type validation (Story, Bug, Task, etc.)
- ✅ Status exclusions (Don't require "Done" tickets)
- ✅ Author/commit exceptions
- ✅ Multiple association sources

**Status**: 🚧 Coming soon

---

### 📊 [threshold-checker/](threshold-checker/)
**For**: Code coverage, quality metrics, performance metrics

**Handles**: Percentage or numeric threshold validation with min/max boundaries

**Use when**: Enforcing coverage percentages, code quality scores, or custom metrics

**Features**:
- ✅ Minimum/maximum thresholds
- ✅ Percentage calculations
- ✅ Multi-metric evaluation
- ✅ Trend analysis support

**Status**: 🚧 Coming soon

---

### ✅ [boolean-check/](boolean-check/)
**For**: Simple pass/fail validations

**Handles**: Boolean value checks, existence checks, simple status validation

**Use when**: Checking if something exists, is enabled, or completed successfully

**Features**:
- ✅ Minimal complexity
- ✅ Fast evaluation
- ✅ Clear pass/fail logic
- ✅ Optional requirement support

**Status**: 🚧 Coming soon

---

### 🎨 [custom/](custom/)
**For**: Any use case not covered above

**Handles**: Fully customizable with comprehensive inline documentation

**Use when**: Building something unique or learning the control structure

**Features**:
- ✅ Blank slate with comments
- ✅ All possible configurations shown
- ✅ Best practice examples
- ✅ Customization guide

**Status**: 🚧 Coming soon

---

## How to Use Templates

### Quick Start

```bash
# 1. Copy the template
cp -r templates/vulnerability-scanner my-snyk-control

# 2. Navigate to it
cd my-snyk-control

# 3. Customize the files
# - Update spec.yaml with your control details
# - Modify mappers for your data format
# - Adjust rule logic for your policy
# - Create test data

# 4. Package and deploy
fianu package --path . -o my-snyk-control.tgz
fianu apply --path my-snyk-control.tgz
```

### Customization Checklist

For each template, you need to customize:

- [ ] **spec.yaml**
  - [ ] `id` - Generate new UUID
  - [ ] `displayKey` - Short identifier (e.g., SAST, TEST)
  - [ ] `path` - Unique control path
  - [ ] `name` - Display name
  - [ ] `description` - What the control does
  - [ ] `relations[].path` - Occurrence path
  - [ ] `relations[].producer.path` - Integration name

- [ ] **mappers/detail.py**
  - [ ] Adjust data extraction for your format
  - [ ] Update field names to match your data
  - [ ] Modify summary calculations if needed

- [ ] **mappers/display.py**
  - [ ] Update description text
  - [ ] Customize tag format
  - [ ] Add/remove violation columns if needed

- [ ] **rule/rule.rego**
  - [ ] Adjust policy logic if needed
  - [ ] Update field references
  - [ ] Modify thresholds or conditions

- [ ] **Test Data**
  - [ ] Create realistic occurrence payloads
  - [ ] Define multiple policy test cases
  - [ ] Test edge cases

### Template Structure

Every template includes:

```
template-name/
├── README.md                    # Template-specific documentation
├── spec.yaml.template           # With TODO markers for customization
├── contents.json
├── mappers/
│   ├── detail.py               # Heavily commented with examples
│   └── display.py              # Multiple format options shown
├── rule/
│   └── rule.rego               # Common patterns demonstrated
├── inputs/
│   └── data/
│       ├── policy_strict.json      # Strict policy example
│       ├── policy_lenient.json     # Lenient policy example
│       └── policy_with_exceptions.json  # With exceptions
└── testing/
    └── payloads/
        ├── occ_pass.json           # Data that should pass
        ├── occ_fail.json           # Data that should fail
        └── occ_edge_case.json      # Edge cases
```

---

## Template Selection Guide

### By Use Case

| Use Case | Template | Why |
|----------|----------|-----|
| Snyk SAST scanning | vulnerability-scanner | Handles SARIF, severity levels |
| JUnit test results | test-results | Test status evaluation |
| Jira PR validation | association-validator | Association checking |
| Code coverage | threshold-checker | Percentage thresholds |
| Build success check | boolean-check | Simple pass/fail |
| Custom integration | custom | Start from scratch |

### By Complexity

| Level | Templates | Good For |
|-------|-----------|----------|
| **Beginner** | boolean-check | Learning the structure |
| **Intermediate** | threshold-checker, test-results | Common patterns |
| **Advanced** | vulnerability-scanner, association-validator | Complex logic |
| **Expert** | custom | Full customization |

### By Data Format

| Format | Template | Notes |
|--------|----------|-------|
| SARIF | vulnerability-scanner | Standard security format |
| JUnit XML | test-results | Standard test format |
| Custom JSON | custom | Build your own parser |
| Boolean/Status | boolean-check | Simple values |
| Metrics/Numbers | threshold-checker | Numeric data |

---

## Customization Examples

### Example 1: Snyk SAST → My Control

Starting with `vulnerability-scanner/`:

```yaml
# spec.yaml changes
path: my.snyk.sast
name: Snyk SAST
relations:
- path: snyk.sast
  producer:
    path: snyk-sast
```

```python
# detail.py changes
def main(occurrence, context):
    # Snyk provides SARIF format
    sarif = occurrence['detail']['scan']
    results = sarif['runs'][0]['results']
    # ... rest of parsing
```

### Example 2: JUnit → My Tests

Starting with `test-results/`:

```yaml
# spec.yaml changes
path: my.junit.tests
name: Unit Tests
relations:
- path: testing.unit.junit
  producer:
    path: junit
```

```python
# detail.py changes
def main(occurrence, context):
    # JUnit provides test results
    tests = occurrence['detail']['testsuites']['testsuite']
    # ... rest of parsing
```

---

## Tips for Success

### DO:
- ✅ Start with the closest matching template
- ✅ Read the template's README thoroughly
- ✅ Test with realistic data
- ✅ Keep error handling from the template
- ✅ Use the provided test cases as examples
- ✅ Add inline comments for complex logic

### DON'T:
- ❌ Skip customization steps (especially UUIDs!)
- ❌ Remove error handling
- ❌ Delete test data directories
- ❌ Change structure without understanding it
- ❌ Mix template patterns (pick one and stick with it)

---

## Getting Help

### Template-Specific Help
Each template has its own README with:
- Detailed usage instructions
- Customization guide
- Common pitfalls
- Related recipes

### General Help
- **[Troubleshooting](../TROUBLESHOOTING.md)** - Common issues
- **[Best Practices](../best-practices/)** - Design guidelines
- **[Reference Docs](../reference/)** - Component specifications
- **[Examples](../examples/)** - See templates in action

### Can't Find the Right Template?
1. Check **[Recipes](../recipes/)** for your specific integration
2. Browse **[Examples](../examples/)** for similar use cases
3. Start with **[custom/](custom/)** template
4. Ask in **[GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)**

---

## Contributing Templates

Have a great template to share? See our **[Contributing Guide](../contributing/)** for how to submit!

---

**Ready to build?** → Choose a template above

**Need more guidance?** → Check out [Recipes](../recipes/)

**Want to see them in action?** → Browse [Examples](../examples/)

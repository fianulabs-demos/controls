# Control Patterns

Reusable code patterns and techniques for common control scenarios. Each pattern includes implementation examples, usage guidelines, and variations.

## Pattern Catalog

### 🔴 [severity-based-evaluation/](severity-based-evaluation/)
**Problem**: Need to enforce different thresholds for different severity levels

**Solution**: Multi-level evaluation with independent thresholds and exceptions

**Use in**: Vulnerability scanners, security analysis, quality metrics

**Example**:
```rego
pass if {
    critical <= data.vulnerabilities.critical.maximum
    high <= data.vulnerabilities.high.maximum
    medium <= data.vulnerabilities.medium.maximum
}
```

**Status**: 🚧 Coming soon

---

### 🚫 [exception-handling/](exception-handling/)
**Problem**: Need to exclude specific items from policy enforcement

**Solution**: Exception lists with flexible matching (ID, CWE, name, etc.)

**Use in**: Any control that needs to allow specific exemptions

**Example**:
```rego
isException(vuln, exceptions) if {
    some exception
    exception = exceptions[_]
    exception == vuln.cwe
}
```

**Status**: 🚧 Coming soon

---

### 📁 [location-exclusions/](location-exclusions/)
**Problem**: Need to exclude certain files/paths from evaluation

**Solution**: Path-based filtering with wildcard support

**Use in**: Security scans, test coverage, code quality

**Example**:
```rego
isExcluded(path) if {
    some exclusion
    exclusion = data.exclusions.locations[_]
    startswith(path, exclusion)
}
```

**Status**: 🚧 Coming soon

---

### 📊 [multi-level-thresholds/](multi-level-thresholds/)
**Problem**: Need both minimum and maximum limits across multiple categories

**Solution**: Hierarchical threshold configuration with independent limits

**Use in**: Test results, quality gates, metric validation

**Example**:
```yaml
tests:
  failed:
    maximum: 0
  passed:
    minimum: 100
  total:
    minimum: 50
```

**Status**: 🚧 Coming soon

---

### 🔗 [association-validation/](association-validation/)
**Problem**: Need to validate external system associations (Jira, GitHub, etc.)

**Solution**: Association extraction and multi-field validation

**Use in**: Code review, ticket tracking, PR validation

**Example**:
```python
def find_association(key, associations):
    for assoc in associations:
        if assoc.get('type') == key:
            return assoc.get('data')
    return None
```

**Status**: 🚧 Coming soon

---

### 🔍 [sarif-parsing/](sarif-parsing/)
**Problem**: Need to parse SARIF format security scan results

**Solution**: Standardized SARIF extraction with rule mapping

**Use in**: SAST tools (Snyk, Checkmarx, GitLab, etc.)

**Example**:
```python
def parse_sarif(occurrence):
    runs = occurrence['detail']['scan']['runs'][0]
    results = runs['results']
    rules = runs['tool']['driver']['rules']
    # ... map results to rules
```

**Status**: 🚧 Coming soon

---

### 🧪 [junit-parsing/](junit-parsing/)
**Problem**: Need to parse JUnit XML test results

**Solution**: Test suite extraction with status categorization

**Use in**: Test frameworks (JUnit, Pytest, etc.)

**Example**:
```python
def parse_junit(occurrence):
    suites = occurrence['detail']['testsuites']
    tests = []
    for suite in suites:
        for case in suite['testcase']:
            tests.append({
                'name': case['name'],
                'status': determine_status(case)
            })
    return tests
```

**Status**: 🚧 Coming soon

---

### 📈 [summary-aggregation/](summary-aggregation/)
**Problem**: Need to roll up detailed data into summary counts

**Solution**: Aggregation functions that group and count items

**Use in**: Any control with large datasets

**Example**:
```python
def summarize(items):
    return {
        'total': len(items),
        'critical': len([i for i in items if i['level'] == 'critical']),
        'high': len([i for i in items if i['level'] == 'high'])
    }
```

**Status**: 🚧 Coming soon

---

## How to Use Patterns

### 1. Identify Your Need
Browse the pattern catalog above to find patterns that match your use case.

### 2. Read the Pattern
Each pattern includes:
- Problem description
- Solution approach
- Complete implementation
- Usage examples
- Variations
- When to use / when not to use

### 3. Copy and Adapt
```bash
# Navigate to the pattern
cd patterns/severity-based-evaluation

# Read the documentation
cat README.md

# Copy example code
cp example.rego my-control/rule/
cp example-spec.yaml my-control/spec.yaml

# Adapt to your needs
```

### 4. Test
Use the provided test cases to verify the pattern works as expected.

---

## Pattern Combinations

Patterns can be combined for complex controls:

### Example: Vulnerability Scanner
- ✅ severity-based-evaluation (critical/high/medium/low)
- ✅ exception-handling (CWE exceptions)
- ✅ location-exclusions (file path filtering)
- ✅ sarif-parsing (data extraction)
- ✅ summary-aggregation (counts by severity)

### Example: Test Results
- ✅ multi-level-thresholds (failed/error/skipped)
- ✅ exception-handling (test class exceptions)
- ✅ junit-parsing (data extraction)
- ✅ summary-aggregation (test counts)

### Example: Jira PR Validation
- ✅ association-validation (extract Jira data)
- ✅ exception-handling (author/commit exceptions)
- ✅ multi-level-thresholds (issue type/status)

---

## Pattern Categories

### Data Extraction Patterns
- sarif-parsing
- junit-parsing
- association-validation
- summary-aggregation

### Evaluation Patterns
- severity-based-evaluation
- multi-level-thresholds
- exception-handling
- location-exclusions

### All-Purpose Patterns
- exception-handling (used in almost every control)
- summary-aggregation (useful for large datasets)

---

## Pattern Structure

Each pattern includes:

```
pattern-name/
├── README.md                   # Pattern documentation
├── example.rego                # Rego implementation
├── example-mapper.py           # Python implementation (if applicable)
├── example-spec.yaml           # Measure structure
├── example-policy.json         # Policy configuration
└── variations/                 # Alternative implementations
    ├── variation1.md
    └── variation2.md
```

---

## Design Principles

Good patterns are:

✅ **Reusable** - Work across multiple controls
✅ **Composable** - Can be combined with other patterns
✅ **Tested** - Include test cases
✅ **Documented** - Clear explanation and examples
✅ **Flexible** - Support variations and customization

---

## Pattern vs Template vs Recipe

| | Pattern | Template | Recipe |
|---|---|---|---|
| **What** | Specific technique | Complete control scaffold | Step-by-step solution |
| **Scope** | One problem/technique | Entire control structure | Specific integration |
| **Use When** | Need a specific solution | Starting new control | Integrating specific tool |
| **Example** | Exception handling | Vulnerability scanner | Snyk SAST integration |

---

## Contributing Patterns

Found a pattern you use frequently? Share it with the community!

See our **[Contributing Guide](../contributing/)** for guidelines on:
- Pattern documentation format
- Code quality standards
- Test requirements
- Submission process

---

## Learning Path

1. **Start with examples**: See patterns in action in [Examples](../examples/)
2. **Try in isolation**: Test individual patterns
3. **Combine patterns**: Build more complex controls
4. **Create variations**: Adapt to your specific needs

---

## Further Reading

- **[Templates](../templates/)** - See patterns used in complete controls
- **[Recipes](../recipes/)** - Patterns applied to specific integrations
- **[Best Practices](../best-practices/)** - When and how to use patterns
- **[Reference](../reference/)** - Deep dive into components

---

**Need a specific technique?** → Browse patterns above

**Want complete examples?** → Check [Templates](../templates/)

**Building something specific?** → See [Recipes](../recipes/)

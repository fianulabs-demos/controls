# Official Controls Testing Framework

Comprehensive testing framework for Fianu official controls. Test before you deploy!

## Overview

This framework provides everything needed to test controls before deployment:

| Testing Level | Tool | Purpose | Coverage |
|--------------|------|---------|----------|
| **Validation** | Shell scripts | File structure, syntax, schema | Quick checks |
| **Unit Tests** | pytest | Mapper logic | Python code |
| **Rule Tests** | OPA | Policy evaluation | Rego rules |
| **Integration** | Scripts | End-to-end | Full control |

## Testing Pyramid

```
       /\
      /  \     Integration Tests (slow, high confidence)
     /____\
    /      \   Rule Tests (medium speed, medium confidence)
   /        \
  /__________\ Unit Tests (fast, low confidence)
 /            \
/______________\ Validation (fastest, basic confidence)
```

## Quick Start

```bash
# 1. Validate structure
./examples/testing/validation/validate-control.sh my-control

# 2. Test mappers
cd examples/testing/mappers
pip install -r requirements.txt
pytest -v

# 3. Test rules
cd examples/testing/rego
./install-opa.sh
./run-opa-tests.sh -v

# 4. Deploy with confidence!
```

## Testing Levels

### 1. Validation (Required)

**Purpose:** Catch file structure and syntax errors before testing

**Location:** `testing/validation/`

**What it checks:**
- ✅ Required files exist
- ✅ YAML/JSON syntax valid
- ✅ Python compiles without errors
- ✅ UUIDs are valid format
- ✅ Spec.yaml schema compliance
- ✅ Reference integrity

**Run:**
```bash
./examples/testing/validation/validate-all.sh
```

**When to run:**
- Before every commit
- In CI/CD pipeline (always)
- Before writing tests

**Learn more:** [Validation Guide](validation/)

---

### 2. Mapper Unit Tests (Recommended)

**Purpose:** Test Python mapper logic in isolation

**Location:** `testing/mappers/`

**What it tests:**
- ✅ Mapper returns correct structure
- ✅ Handles edge cases (None, empty, malformed)
- ✅ Data types are correct
- ✅ Business logic is correct
- ✅ Error handling works

**Run:**
```bash
cd examples/testing/mappers
./run-tests.sh --coverage
```

**When to run:**
- After mapper changes
- In CI/CD pipeline
- Before major releases

**Learn more:** [Mapper Testing Guide](mappers/)

---

### 3. Rego Rule Tests (Recommended)

**Purpose:** Test policy evaluation logic

**Location:** `testing/rego/`

**What it tests:**
- ✅ Pass conditions work correctly
- ✅ Fail conditions trigger appropriately
- ✅ Exceptions are honored
- ✅ Thresholds are enforced
- ✅ Edge cases handled gracefully

**Run:**
```bash
cd examples/testing/rego
./run-opa-tests.sh --coverage
```

**When to run:**
- After rule changes
- In CI/CD pipeline
- Before deploying policy updates

**Learn more:** [Rego Testing Guide](rego/)

---

### 4. Integration Tests (Optional)

**Purpose:** Test full control end-to-end

**Location:** `testing/integration/`

**What it tests:**
- ✅ Full control evaluation flow
- ✅ Mapper → Rule → Display chain works
- ✅ Real test data produces expected results
- ✅ Violations are recorded correctly

**Run:**
```bash
cd examples/testing/integration
./test-control.sh my-control
```

**When to run:**
- Before production deployment
- For critical controls
- After major refactors

**Learn more:** [Integration Testing Guide](integration/)

## Test Coverage Goals

| Component | Minimum | Target | Excellent |
|-----------|---------|--------|-----------|
| Mappers | 60% | 80% | 90%+ |
| Rules | 70% | 85% | 95%+ |
| Overall | 65% | 80% | 90%+ |

## Testing Workflow

### Development Workflow

```bash
# 1. Make changes
vim my-control/mappers/detail.py

# 2. Validate
./examples/testing/validation/validate-control.sh my-control

# 3. Run unit tests
cd examples/testing/mappers
pytest test_detail.py -v

# 4. Run rule tests (if rule changed)
cd ../rego
./run-opa-tests.sh

# 5. Commit with confidence
git add .
git commit -m "Update detail mapper"
```

### CI/CD Workflow

```yaml
# GitHub Actions example
- name: Validate
  run: ./examples/testing/validation/validate-all.sh

- name: Test Mappers
  run: |
    cd examples/testing/mappers
    pytest --cov=../../mappers

- name: Test Rules
  run: |
    cd examples/testing/rego
    ./run-opa-tests.sh --coverage

- name: Deploy
  if: success()
  run: ./scripts/apply-all.sh
```

## Testing Best Practices

### DO:

✅ **Test before deploying** - Always
✅ **Write tests first** - TDD when possible
✅ **Test edge cases** - None, empty, malformed
✅ **Keep tests fast** - Unit tests < 1s each
✅ **Run tests locally** - Before pushing
✅ **Use test fixtures** - Reuse test data
✅ **Test failure cases** - Not just happy path
✅ **Maintain coverage** - Keep above 80%

### DON'T:

❌ **Skip validation** - It catches basic errors
❌ **Only test happy path** - Test edge cases
❌ **Test in production** - Test locally first
❌ **Ignore failing tests** - Fix immediately
❌ **Write flaky tests** - Tests should be deterministic
❌ **Test external services** - Mock dependencies
❌ **Hardcode test data** - Use fixtures
❌ **Deploy without testing** - Never

## Common Testing Patterns

### Testing Mapper Returns Structure

```python
def test_detail_structure(detail_mapper, sample_occurrence):
    result = detail_mapper.main(sample_occurrence, {})

    assert isinstance(result, dict)
    assert 'summary' in result
    assert isinstance(result['summary'], dict)
```

### Testing Edge Cases

```python
def test_handles_empty_input(detail_mapper):
    result = detail_mapper.main({}, {})
    assert isinstance(result, dict)  # Should not crash

def test_handles_none_input(detail_mapper):
    result = detail_mapper.main(None, {})
    # Should either return dict or raise specific error
```

### Testing Rego Pass Conditions

```rego
test_pass_with_clean_data if {
    occurrence := {"detail": {"vulnerabilities": []}}
    policy := {"required": true, "vulnerabilities": {"critical": {"maximum": 0}}}

    pass with input as occurrence
        with data as policy
}
```

### Testing Rego Exceptions

```rego
test_exception_excludes_vulnerability if {
    occurrence := {"detail": {"vulnerabilities": [{
        "level": "critical",
        "cwe": ["CWE-79"]
    }]}}

    policy := {"vulnerabilities": {"critical": {
        "maximum": 0,
        "exceptions": ["CWE-79"]  # Should exclude this
    }}}

    pass with input as occurrence
        with data as policy
}
```

## Troubleshooting

### Tests Fail Locally But Pass in CI

**Causes:**
- Different Python versions
- Missing dependencies
- Different file paths

**Solutions:**
```bash
# Use same Python version
python3 --version

# Install exact dependencies
pip install -r requirements.txt

# Use Path objects, not strings
from pathlib import Path
```

### Tests Are Slow

**Causes:**
- Too many integration tests
- Not using fixtures
- Testing external services

**Solutions:**
```bash
# Run only fast tests
pytest -m "not slow"

# Use fixtures for test data
@pytest.fixture(scope="session")

# Mock external services
@pytest.fixture
def mock_api():
    with patch('requests.get') as mock:
        yield mock
```

### Coverage Is Low

**Causes:**
- Missing edge case tests
- Not testing error paths
- Complex code

**Solutions:**
```bash
# See uncovered lines
pytest --cov=mappers --cov-report=term-missing

# Generate HTML report
pytest --cov=mappers --cov-report=html
open htmlcov/index.html
```

## CI/CD Integration

### GitHub Actions

```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3

    - name: Validate
      run: ./examples/testing/validation/validate-all.sh

    - name: Test Mappers
      run: |
        pip install -r examples/testing/mappers/requirements.txt
        cd examples/testing/mappers
        pytest --cov=../../mappers --cov-report=xml

    - name: Test Rules
      run: |
        curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
        chmod +x opa && sudo mv opa /usr/local/bin/
        cd examples/testing/rego
        ./run-opa-tests.sh
```

See full examples: [CI/CD Pipelines](../deployment/pipelines/)

## Test Data Management

### Fixture Organization

```
testing/
├── payloads/
│   ├── occ_passing.json    # Should pass
│   ├── occ_failing.json    # Should fail
│   └── occ_edge_cases.json # Edge cases
├── mappers/
│   ├── conftest.py         # Shared fixtures
│   └── test_*.py           # Tests
└── rego/
    └── rule_test.rego      # Rego tests with fixtures
```

### Fixture Naming

```
occ_<scenario>.json         # Occurrences
policy_<scenario>.json      # Policies

Examples:
- occ_passing.json
- occ_failing.json
- occ_empty.json
- policy_strict.json
- policy_lenient.json
```

## Next Steps

1. **[Validation](validation/)** - Start with file validation
2. **[Mapper Tests](mappers/)** - Add mapper unit tests
3. **[Rego Tests](rego/)** - Test policy rules
4. **[Integration Tests](integration/)** - End-to-end testing
5. **[CI/CD](../deployment/pipelines/)** - Add to pipeline

## Resources

- **[Testing Quick Start](../TESTING_QUICKSTART.md)** - 30-minute guide
- **[pytest Documentation](https://docs.pytest.org/)** - pytest docs
- **[OPA Testing](https://www.openpolicyagent.org/docs/latest/policy-testing/)** - OPA test docs
- **[GitHub Actions](../deployment/pipelines/github-actions/)** - CI/CD workflows

---

**Questions?** [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

**Found a bug?** [GitHub Issues](https://github.com/fianulabs/official-controls/issues)

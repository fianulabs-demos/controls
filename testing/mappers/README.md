# Mapper Unit Testing

Comprehensive unit testing framework for Python mappers using pytest.

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run all tests
./run-tests.sh

# Run with coverage
./run-tests.sh --coverage

# Run verbose
./run-tests.sh -v
```

## Overview

Unit tests ensure your mappers:
- ✅ Handle valid input correctly
- ✅ Handle edge cases gracefully
- ✅ Return expected structure
- ✅ Don't crash on bad input
- ✅ Are consistent across calls

## Files in This Directory

- **test_detail.py** - Example unit tests for detail.py mapper
- **test_display.py** - Example unit tests for display.py mapper
- **conftest.py** - Shared pytest fixtures and configuration
- **requirements.txt** - Testing dependencies
- **run-tests.sh** - Test runner script
- **README.md** - This file

## Setup

### 1. Install Dependencies

```bash
# Option 1: System-wide
pip install -r requirements.txt

# Option 2: Virtual environment (recommended)
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Verify Installation

```bash
pytest --version
```

## Running Tests

### Basic Usage

```bash
# Run all tests
pytest

# Or use the helper script
./run-tests.sh
```

### With Options

```bash
# Verbose output
./run-tests.sh -v

# With coverage report
./run-tests.sh --coverage

# Generate HTML coverage report
./run-tests.sh --html

# Skip slow tests
./run-tests.sh --fast

# Exit on first failure
./run-tests.sh -x

# Run specific test
./run-tests.sh -k test_main_returns_dict

# Watch mode (rerun on changes)
./run-tests.sh --watch
```

### Advanced pytest Options

```bash
# Run tests in parallel (faster)
pytest -n auto

# Show local variables on failure
pytest --showlocals

# Only run failed tests from last run
pytest --lf

# Run failed tests first, then others
pytest --ff

# Stop after N failures
pytest --maxfail=3
```

## Writing Tests

### Test Structure

Tests should follow this pattern:

```python
def test_function_name(fixtures):
    # 1. Arrange - Setup test data
    occurrence = {...}

    # 2. Act - Call the function
    result = detail_mapper.main(occurrence, {})

    # 3. Assert - Check results
    assert 'summary' in result
```

### Example: Test detail.py

```python
import pytest

def test_detail_returns_summary(detail_mapper, sample_occurrence):
    """Detail mapper should return a summary field."""
    result = detail_mapper.main(sample_occurrence, {})

    assert 'summary' in result
    assert isinstance(result['summary'], dict)
```

### Example: Test display.py

```python
def test_display_returns_tag(display_mapper, sample_occurrence, sample_attestation):
    """Display mapper should return a tag."""
    result = display_mapper.main(sample_occurrence, sample_attestation, {})

    assert 'tag' in result
    assert isinstance(result['tag'], str)
    assert len(result['tag']) > 0
```

## Available Fixtures

Fixtures are defined in `conftest.py` and automatically available in tests.

### Data Loading Fixtures

```python
def test_with_test_payload(load_test_payload, detail_mapper):
    """Load specific test payload."""
    occurrence = load_test_payload("occ_case_1.json")
    result = detail_mapper.main(occurrence, {})
    assert result is not None

def test_with_policy_data(load_policy_data):
    """Load specific policy data."""
    policy = load_policy_data("policy_case_1.json")
    assert 'required' in policy

def test_all_payloads(all_test_payloads, detail_mapper):
    """Test with all available payloads."""
    for filename, payload in all_test_payloads:
        result = detail_mapper.main(payload, {})
        assert isinstance(result, dict)
```

### Mapper Fixtures

```python
def test_detail_mapper(detail_mapper):
    """detail_mapper fixture provides the imported detail module."""
    assert hasattr(detail_mapper, 'main')

def test_display_mapper(display_mapper):
    """display_mapper fixture provides the imported display module."""
    assert hasattr(display_mapper, 'main')
```

### Common Data Fixtures

```python
def test_empty_occurrence(empty_occurrence, detail_mapper):
    """Test with empty occurrence."""
    result = detail_mapper.main(empty_occurrence, {})
    assert isinstance(result, dict)

def test_with_sample_policy(sample_policy):
    """Test with sample policy configuration."""
    assert sample_policy['required'] == True
```

## Test Categories

### 1. Basic Functionality Tests

Verify fundamental requirements:

```python
class TestBasicFunctionality:
    def test_mapper_has_main_function(self, detail_mapper):
        """Mapper must have a main() function."""
        assert hasattr(detail_mapper, 'main')

    def test_main_returns_dict(self, detail_mapper, sample_occurrence):
        """main() must return a dictionary."""
        result = detail_mapper.main(sample_occurrence, {})
        assert isinstance(result, dict)
```

### 2. Output Structure Tests

Verify correct output format:

```python
class TestOutputStructure:
    def test_returns_summary_field(self, detail_mapper, sample_occurrence):
        """Output should have a 'summary' field."""
        result = detail_mapper.main(sample_occurrence, {})
        assert 'summary' in result

    def test_summary_is_dict(self, detail_mapper, sample_occurrence):
        """Summary field should be a dictionary."""
        result = detail_mapper.main(sample_occurrence, {})
        assert isinstance(result['summary'], dict)
```

### 3. Edge Case Tests

Verify error handling:

```python
class TestEdgeCases:
    def test_handles_empty_occurrence(self, detail_mapper, empty_occurrence):
        """Mapper should handle empty occurrence."""
        result = detail_mapper.main(empty_occurrence, {})
        assert isinstance(result, dict)

    def test_handles_none_input(self, detail_mapper):
        """Mapper should handle None input gracefully."""
        try:
            result = detail_mapper.main(None, {})
            assert result is not None
        except (TypeError, AttributeError):
            pass  # Acceptable to raise error on None
```

### 4. Data Type Tests

Verify correct data types:

```python
class TestDataTypes:
    def test_summary_counts_are_numeric(self, detail_mapper, sample_occurrence):
        """Summary count fields should be numeric."""
        result = detail_mapper.main(sample_occurrence, {})
        summary = result['summary']

        for key, value in summary.items():
            if 'count' in key or key in ['total']:
                assert isinstance(value, (int, float))
```

### 5. Business Logic Tests

Verify control-specific logic:

```python
class TestBusinessLogic:
    def test_severity_counts_sum_to_total(self, detail_mapper, sample_occurrence):
        """For vulnerability scanner, severities should sum to total."""
        result = detail_mapper.main(sample_occurrence, {})
        summary = result['summary']

        total = summary.get('total', 0)
        severity_sum = (
            summary.get('critical', 0) +
            summary.get('high', 0) +
            summary.get('medium', 0) +
            summary.get('low', 0)
        )

        assert severity_sum == total
```

## Coverage

### Generate Coverage Report

```bash
# Terminal report
pytest --cov=../../mappers --cov-report=term-missing

# HTML report
pytest --cov=../../mappers --cov-report=html

# Open HTML report
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
```

### Coverage Goals

- **Aim for 80%+ coverage**
- Focus on critical paths first
- Don't obsess over 100% coverage
- Test edge cases thoroughly

### Exclude from Coverage

Create `.coveragerc` to exclude certain lines:

```ini
[run]
omit =
    */tests/*
    */conftest.py

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
```

## Best Practices

### DO:

✅ **Test edge cases** - None, empty, malformed data
✅ **Test return types** - Ensure correct data types
✅ **Test error handling** - Mapper shouldn't crash
✅ **Use fixtures** - Reuse test data
✅ **Name tests clearly** - `test_handles_empty_occurrence`
✅ **One assertion per test** - Or closely related assertions
✅ **Run tests frequently** - Before every commit

### DON'T:

❌ **Test external dependencies** - Mock integrations
❌ **Make tests depend on each other** - Keep independent
❌ **Hardcode test data in tests** - Use fixtures
❌ **Skip edge case tests** - They catch most bugs
❌ **Write tests after deployment** - Write first!

## Troubleshooting

### Import Errors

**Problem:**
```
ImportError: No module named 'detail'
```

**Solution:**
```bash
# Ensure conftest.py is present (adds mappers to path)
# Or run tests from correct directory
cd examples/testing/mappers
pytest
```

### Fixture Not Found

**Problem:**
```
fixture 'detail_mapper' not found
```

**Solution:**
```bash
# Ensure conftest.py is in the same directory
ls conftest.py

# Check fixture is defined
grep "def detail_mapper" conftest.py
```

### Tests Pass Locally But Fail in CI

**Causes:**
- Different Python versions
- Missing dependencies
- Path issues
- Test data not committed

**Solution:**
```bash
# Pin Python version in CI
# Install all dependencies
# Use absolute paths or Path objects
# Commit test data files
```

## Integration with CI/CD

### GitHub Actions

```yaml
name: Test Mappers

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r examples/testing/mappers/requirements.txt

      - name: Run tests
        run: |
          cd examples/testing/mappers
          pytest --cov=../../mappers --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

### GitLab CI/CD

```yaml
test:mappers:
  stage: test
  script:
    - pip install -r examples/testing/mappers/requirements.txt
    - cd examples/testing/mappers
    - pytest --cov=../../mappers --cov-report=term
```

### Jenkins

```groovy
stage('Test Mappers') {
    steps {
        sh 'pip install -r examples/testing/mappers/requirements.txt'
        sh 'cd examples/testing/mappers && pytest --cov=../../mappers'
    }
}
```

## Next Steps

- **[Rego Testing](../rego/)** - Test your Rego rules with OPA
- **[Integration Testing](../integration/)** - End-to-end control testing
- **[Validation](../validation/)** - File structure and schema validation
- **[CI/CD Integration](../ci-cd/)** - Add tests to your pipeline

---

**Need help?** See [Troubleshooting Guide](../../TROUBLESHOOTING.md) or [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

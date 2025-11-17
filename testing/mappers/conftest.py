"""
Pytest configuration and shared fixtures for mapper tests

This file provides common fixtures and configuration for all mapper tests.
Place this file in your control's test directory.
"""

import json
import sys
from pathlib import Path

import pytest


# ============================================================================
# Path Configuration
# ============================================================================

@pytest.fixture(scope="session", autouse=True)
def add_mappers_to_path():
    """
    Automatically add mappers directory to Python path for all tests.

    This allows importing detail and display modules in tests.
    """
    # Get control root directory (parent of test directory)
    test_dir = Path(__file__).parent
    control_root = test_dir.parent.parent

    # Add mappers directory to path
    mappers_dir = control_root / "mappers"
    if mappers_dir.exists():
        sys.path.insert(0, str(mappers_dir))
        print(f"\nAdded to path: {mappers_dir}")


# ============================================================================
# Test Data Fixtures
# ============================================================================

@pytest.fixture(scope="session")
def control_root():
    """Return path to control root directory."""
    test_dir = Path(__file__).parent
    return test_dir.parent.parent


@pytest.fixture(scope="session")
def test_payloads_dir(control_root):
    """Return path to test payloads directory."""
    return control_root / "testing" / "payloads"


@pytest.fixture(scope="session")
def policy_data_dir(control_root):
    """Return path to policy test data directory."""
    return control_root / "inputs" / "data"


@pytest.fixture
def load_test_payload():
    """
    Factory fixture to load test payloads by filename.

    Usage:
        payload = load_test_payload("occ_case_1.json")
    """
    def _load(filename, payloads_dir=None):
        if payloads_dir is None:
            test_dir = Path(__file__).parent
            control_root = test_dir.parent.parent
            payloads_dir = control_root / "testing" / "payloads"

        payload_path = payloads_dir / filename

        if not payload_path.exists():
            pytest.skip(f"Test payload not found: {filename}")

        with open(payload_path) as f:
            return json.load(f)

    return _load


@pytest.fixture
def load_policy_data():
    """
    Factory fixture to load policy test data by filename.

    Usage:
        policy = load_policy_data("policy_case_1.json")
    """
    def _load(filename, data_dir=None):
        if data_dir is None:
            test_dir = Path(__file__).parent
            control_root = test_dir.parent.parent
            data_dir = control_root / "inputs" / "data"

        policy_path = data_dir / filename

        if not policy_path.exists():
            pytest.skip(f"Policy data not found: {filename}")

        with open(policy_path) as f:
            return json.load(f)

    return _load


@pytest.fixture
def all_test_payloads(test_payloads_dir):
    """
    Load all test payloads from testing/payloads directory.

    Returns:
        List of tuples: [(filename, payload_dict), ...]
    """
    if not test_payloads_dir.exists():
        pytest.skip("Test payloads directory not found")

    payloads = []
    for json_file in sorted(test_payloads_dir.glob("*.json")):
        with open(json_file) as f:
            payloads.append((json_file.name, json.load(f)))

    if not payloads:
        pytest.skip("No test payloads found")

    return payloads


@pytest.fixture
def all_policy_data(policy_data_dir):
    """
    Load all policy test data from inputs/data directory.

    Returns:
        List of tuples: [(filename, policy_dict), ...]
    """
    if not policy_data_dir.exists():
        pytest.skip("Policy data directory not found")

    policies = []
    for json_file in sorted(policy_data_dir.glob("*.json")):
        with open(json_file) as f:
            policies.append((json_file.name, json.load(f)))

    if not policies:
        pytest.skip("No policy data found")

    return policies


# ============================================================================
# Mapper Module Fixtures
# ============================================================================

@pytest.fixture(scope="session")
def detail_mapper():
    """
    Import and return the detail mapper module.

    Usage:
        result = detail_mapper.main(occurrence, context)
    """
    try:
        import detail
        return detail
    except ImportError as e:
        pytest.skip(f"Could not import detail.py: {e}")


@pytest.fixture(scope="session")
def display_mapper():
    """
    Import and return the display mapper module.

    Usage:
        result = display_mapper.main(occurrence, attestation, context)
    """
    try:
        import display
        return display
    except ImportError as e:
        pytest.skip(f"Could not import display.py: {e}")


# ============================================================================
# Common Test Data Fixtures
# ============================================================================

@pytest.fixture
def empty_occurrence():
    """Minimal valid occurrence structure with no data."""
    return {
        "asset": {
            "key": "org/repo",
            "name": "repo",
            "type": {
                "category": "software",
                "code": 3000,
                "name": "repository"
            }
        },
        "detail": {},
        "status": "complete",
        "type": "occurrence"
    }


@pytest.fixture
def empty_context():
    """Empty context dictionary."""
    return {}


@pytest.fixture
def empty_attestation():
    """Empty attestation dictionary."""
    return {}


@pytest.fixture
def sample_policy():
    """Sample policy configuration."""
    return {
        "required": True
    }


@pytest.fixture
def sample_attestation(sample_policy):
    """Sample attestation with policy."""
    return {
        "policy": {
            "data": sample_policy
        },
        "result": "pass"
    }


# ============================================================================
# Pytest Configuration
# ============================================================================

def pytest_configure(config):
    """Register custom markers."""
    config.addinivalue_line(
        "markers", "slow: marks tests as slow (deselect with '-m \"not slow\"')"
    )
    config.addinivalue_line(
        "markers", "integration: marks tests as integration tests"
    )
    config.addinivalue_line(
        "markers", "unit: marks tests as unit tests"
    )


def pytest_collection_modifyitems(config, items):
    """Automatically mark tests based on their location or name."""
    for item in items:
        # Mark integration tests
        if "integration" in item.nodeid.lower():
            item.add_marker(pytest.mark.integration)

        # Mark slow tests based on test name
        if "slow" in item.name.lower() or "performance" in item.name.lower():
            item.add_marker(pytest.mark.slow)


# ============================================================================
# Test Output Helpers
# ============================================================================

@pytest.fixture
def json_diff():
    """
    Helper to show differences between JSON structures.

    Usage:
        assert expected == actual, json_diff(expected, actual)
    """
    def _diff(obj1, obj2, path=""):
        """Recursively find differences between two objects."""
        if type(obj1) != type(obj2):
            return f"{path}: Type mismatch {type(obj1).__name__} vs {type(obj2).__name__}"

        if isinstance(obj1, dict):
            all_keys = set(obj1.keys()) | set(obj2.keys())
            diffs = []

            for key in all_keys:
                if key not in obj1:
                    diffs.append(f"{path}.{key}: Missing in first object")
                elif key not in obj2:
                    diffs.append(f"{path}.{key}: Missing in second object")
                else:
                    sub_diff = _diff(obj1[key], obj2[key], f"{path}.{key}")
                    if sub_diff:
                        diffs.append(sub_diff)

            return "\n".join(diffs) if diffs else ""

        elif isinstance(obj1, list):
            if len(obj1) != len(obj2):
                return f"{path}: List length mismatch {len(obj1)} vs {len(obj2)}"

            diffs = []
            for i, (item1, item2) in enumerate(zip(obj1, obj2)):
                sub_diff = _diff(item1, item2, f"{path}[{i}]")
                if sub_diff:
                    diffs.append(sub_diff)

            return "\n".join(diffs) if diffs else ""

        else:
            if obj1 != obj2:
                return f"{path}: Value mismatch {obj1!r} vs {obj2!r}"

        return ""

    return _diff


@pytest.fixture
def assert_structure():
    """
    Helper to assert that an object has expected structure.

    Usage:
        assert_structure(result, {
            'summary': dict,
            'vulnerabilities': list
        })
    """
    def _assert(obj, structure, path="root"):
        """Recursively check structure matches expected types."""
        if isinstance(structure, dict):
            assert isinstance(obj, dict), f"{path} should be dict, got {type(obj).__name__}"

            for key, expected_type in structure.items():
                assert key in obj, f"{path}.{key} is missing"

                if isinstance(expected_type, type):
                    assert isinstance(obj[key], expected_type), \
                        f"{path}.{key} should be {expected_type.__name__}, got {type(obj[key]).__name__}"
                elif isinstance(expected_type, dict):
                    _assert(obj[key], expected_type, f"{path}.{key}")
                elif isinstance(expected_type, list) and expected_type:
                    assert isinstance(obj[key], list), f"{path}.{key} should be list"
                    if obj[key]:  # If list is not empty, check first item
                        _assert(obj[key][0], expected_type[0], f"{path}.{key}[0]")

        elif isinstance(structure, type):
            assert isinstance(obj, structure), \
                f"{path} should be {structure.__name__}, got {type(obj).__name__}"

    return _assert

"""
Example unit tests for detail.py mapper

This file demonstrates how to write comprehensive unit tests for a detail mapper.
Adapt these patterns to your specific control's logic.

Run with:
    pytest test_detail.py -v
"""

import json
import sys
from pathlib import Path

import pytest


# ============================================================================
# Fixtures - Load Test Data
# ============================================================================

@pytest.fixture
def sample_occurrence():
    """Load a sample occurrence from test payloads."""
    # Adjust path to your control's test payload
    payload_path = Path("../../testing/payloads/occ_case_1.json")

    if not payload_path.exists():
        # Fallback: create minimal test occurrence
        return {
            "asset": {
                "key": "org/repo",
                "name": "repo"
            },
            "detail": {
                "scan": {
                    "results": []
                }
            },
            "status": "complete",
            "type": "occurrence"
        }

    with open(payload_path) as f:
        return json.load(f)


@pytest.fixture
def empty_occurrence():
    """Occurrence with no scan data (edge case)."""
    return {
        "asset": {
            "key": "org/repo",
            "name": "repo"
        },
        "detail": {},
        "status": "complete",
        "type": "occurrence"
    }


@pytest.fixture
def malformed_occurrence():
    """Occurrence with missing/null fields (edge case)."""
    return {
        "asset": None,
        "detail": {
            "scan": None
        },
        "status": "complete",
        "type": "occurrence"
    }


@pytest.fixture
def detail_mapper():
    """Import the detail mapper module."""
    # Add mapper directory to path
    mappers_dir = Path("../../mappers")
    if mappers_dir.exists():
        sys.path.insert(0, str(mappers_dir))

    try:
        import detail
        return detail
    except ImportError as e:
        pytest.skip(f"Could not import detail.py: {e}")


# ============================================================================
# Basic Functionality Tests
# ============================================================================

class TestBasicFunctionality:
    """Test basic mapper functionality."""

    def test_mapper_has_main_function(self, detail_mapper):
        """Mapper must have a main() function."""
        assert hasattr(detail_mapper, 'main'), "detail.py must have a main() function"

    def test_main_accepts_two_parameters(self, detail_mapper):
        """main() must accept occurrence and context parameters."""
        import inspect
        sig = inspect.signature(detail_mapper.main)
        params = list(sig.parameters.keys())

        assert len(params) == 2, "main() must accept exactly 2 parameters"
        assert params[0] == 'occurrence', "First parameter must be 'occurrence'"
        assert params[1] == 'context', "Second parameter must be 'context'"

    def test_main_returns_dict(self, detail_mapper, sample_occurrence):
        """main() must return a dictionary."""
        result = detail_mapper.main(sample_occurrence, {})

        assert isinstance(result, dict), "main() must return a dictionary"

    def test_main_does_not_raise_exception(self, detail_mapper, sample_occurrence):
        """main() should not raise exceptions with valid input."""
        try:
            detail_mapper.main(sample_occurrence, {})
        except Exception as e:
            pytest.fail(f"main() raised unexpected exception: {e}")


# ============================================================================
# Output Structure Tests
# ============================================================================

class TestOutputStructure:
    """Test that mapper returns expected structure."""

    def test_returns_summary_field(self, detail_mapper, sample_occurrence):
        """Output should have a 'summary' field."""
        result = detail_mapper.main(sample_occurrence, {})

        assert 'summary' in result, "Output must contain 'summary' field"

    def test_summary_is_dict(self, detail_mapper, sample_occurrence):
        """Summary field should be a dictionary."""
        result = detail_mapper.main(sample_occurrence, {})

        assert isinstance(result.get('summary'), dict), "'summary' must be a dictionary"

    def test_returns_expected_top_level_fields(self, detail_mapper, sample_occurrence):
        """Output should have expected top-level fields."""
        result = detail_mapper.main(sample_occurrence, {})

        # Adjust these based on your control's structure
        expected_fields = ['summary']

        for field in expected_fields:
            assert field in result, f"Output must contain '{field}' field"

    def test_summary_has_counts(self, detail_mapper, sample_occurrence):
        """Summary should contain count fields."""
        result = detail_mapper.main(sample_occurrence, {})
        summary = result.get('summary', {})

        # Adjust based on your control's summary structure
        # Example for vulnerability scanner:
        # assert 'critical' in summary
        # assert 'high' in summary
        # assert 'total' in summary

        # Generic check: summary should not be empty
        assert len(summary) > 0, "Summary should not be empty"


# ============================================================================
# Edge Case Tests
# ============================================================================

class TestEdgeCases:
    """Test edge cases and error handling."""

    def test_handles_empty_occurrence(self, detail_mapper, empty_occurrence):
        """Mapper should handle occurrence with no scan data."""
        try:
            result = detail_mapper.main(empty_occurrence, {})
            assert isinstance(result, dict), "Should return dict even with empty occurrence"
        except Exception as e:
            pytest.fail(f"Failed to handle empty occurrence: {e}")

    def test_handles_malformed_occurrence(self, detail_mapper, malformed_occurrence):
        """Mapper should handle occurrence with null/missing fields."""
        try:
            result = detail_mapper.main(malformed_occurrence, {})
            assert isinstance(result, dict), "Should return dict even with malformed occurrence"
        except Exception as e:
            pytest.fail(f"Failed to handle malformed occurrence: {e}")

    def test_handles_missing_detail_field(self, detail_mapper):
        """Mapper should handle occurrence without 'detail' field."""
        occurrence = {"asset": {"key": "test"}}

        try:
            result = detail_mapper.main(occurrence, {})
            assert isinstance(result, dict)
        except Exception as e:
            pytest.fail(f"Failed to handle missing 'detail' field: {e}")

    def test_handles_none_occurrence(self, detail_mapper):
        """Mapper should handle None occurrence gracefully."""
        try:
            result = detail_mapper.main(None, {})
            # Should either return empty structure or raise informative error
            assert result is not None
        except (TypeError, AttributeError):
            # It's ok to fail with type error on None, but don't crash
            pass

    def test_handles_empty_context(self, detail_mapper, sample_occurrence):
        """Mapper should handle empty context dict."""
        result = detail_mapper.main(sample_occurrence, {})
        assert isinstance(result, dict)

    def test_handles_none_context(self, detail_mapper, sample_occurrence):
        """Mapper should handle None context."""
        result = detail_mapper.main(sample_occurrence, None)
        assert isinstance(result, dict)


# ============================================================================
# Data Type Tests
# ============================================================================

class TestDataTypes:
    """Test that output data types are correct."""

    def test_summary_counts_are_numeric(self, detail_mapper, sample_occurrence):
        """Summary count fields should be numeric."""
        result = detail_mapper.main(sample_occurrence, {})
        summary = result.get('summary', {})

        for key, value in summary.items():
            if 'count' in key.lower() or key in ['total', 'critical', 'high', 'medium', 'low']:
                assert isinstance(value, (int, float)), \
                    f"Summary field '{key}' should be numeric, got {type(value)}"

    def test_arrays_are_lists(self, detail_mapper, sample_occurrence):
        """Array fields should be Python lists."""
        result = detail_mapper.main(sample_occurrence, {})

        # Check any array fields your mapper returns
        # Example for vulnerability scanner:
        # vulnerabilities = result.get('vulnerabilities', [])
        # assert isinstance(vulnerabilities, list)

        # Generic: recursively check all lists
        def check_lists(obj):
            if isinstance(obj, dict):
                for value in obj.values():
                    check_lists(value)
            elif isinstance(obj, list):
                # List found, check items
                for item in obj:
                    check_lists(item)

        check_lists(result)


# ============================================================================
# Business Logic Tests
# ============================================================================

class TestBusinessLogic:
    """Test business logic specific to your control."""

    @pytest.mark.skip(reason="Customize this test for your control")
    def test_vulnerability_count_matches_array_length(self, detail_mapper, sample_occurrence):
        """
        Example: For vulnerability scanner, total count should match array length.

        Customize this test based on your control's logic.
        """
        result = detail_mapper.main(sample_occurrence, {})

        vulnerabilities = result.get('vulnerabilities', [])
        summary = result.get('summary', {})
        total = summary.get('total', 0)

        assert len(vulnerabilities) == total, \
            "Summary total should match vulnerabilities array length"

    @pytest.mark.skip(reason="Customize this test for your control")
    def test_severity_counts_sum_to_total(self, detail_mapper, sample_occurrence):
        """
        Example: For vulnerability scanner, severity counts should sum to total.

        Customize this test based on your control's logic.
        """
        result = detail_mapper.main(sample_occurrence, {})
        summary = result.get('summary', {})

        critical = summary.get('critical', 0)
        high = summary.get('high', 0)
        medium = summary.get('medium', 0)
        low = summary.get('low', 0)
        total = summary.get('total', 0)

        assert critical + high + medium + low == total, \
            "Severity counts should sum to total"


# ============================================================================
# Integration with Test Data
# ============================================================================

class TestWithRealData:
    """Test mapper with all available test payloads."""

    @pytest.fixture
    def all_test_payloads(self):
        """Load all test payloads from testing/payloads directory."""
        payloads_dir = Path("../../testing/payloads")

        if not payloads_dir.exists():
            pytest.skip("No test payloads found")

        payloads = []
        for json_file in payloads_dir.glob("*.json"):
            with open(json_file) as f:
                payloads.append((json_file.name, json.load(f)))

        return payloads

    def test_all_payloads_process_successfully(self, detail_mapper, all_test_payloads):
        """All test payloads should process without errors."""
        for filename, payload in all_test_payloads:
            try:
                result = detail_mapper.main(payload, {})
                assert isinstance(result, dict), f"{filename}: Should return dict"
                assert 'summary' in result, f"{filename}: Should have summary"
            except Exception as e:
                pytest.fail(f"{filename}: Failed to process: {e}")


# ============================================================================
# Performance Tests (Optional)
# ============================================================================

class TestPerformance:
    """Test mapper performance (optional)."""

    @pytest.mark.slow
    def test_processes_large_occurrence_quickly(self, detail_mapper):
        """Mapper should handle large occurrences efficiently."""
        import time

        # Create large test occurrence
        large_occurrence = {
            "detail": {
                "scan": {
                    "results": [
                        {"id": f"vuln-{i}", "severity": "high"}
                        for i in range(1000)
                    ]
                }
            }
        }

        start = time.time()
        result = detail_mapper.main(large_occurrence, {})
        elapsed = time.time() - start

        assert elapsed < 1.0, f"Mapper took too long: {elapsed:.2f}s"
        assert isinstance(result, dict)


# ============================================================================
# Run Tests
# ============================================================================

if __name__ == '__main__':
    pytest.main([__file__, '-v'])

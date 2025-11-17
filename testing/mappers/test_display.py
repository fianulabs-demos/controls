"""
Example unit tests for display.py mapper

This file demonstrates how to write comprehensive unit tests for a display mapper.
Adapt these patterns to your specific control's logic.

Run with:
    pytest test_display.py -v
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
    """
    Load occurrence with mapped detail from detail.py output.

    In reality, the occurrence passed to display.py has already been
    processed by detail.py, so its 'detail' field contains the mapper output.
    """
    return {
        "asset": {
            "key": "org/repo",
            "name": "repo"
        },
        "detail": {
            "summary": {
                "critical": 2,
                "high": 5,
                "medium": 10,
                "low": 20,
                "total": 37
            },
            "vulnerabilities": []
        },
        "status": "complete",
        "type": "occurrence"
    }


@pytest.fixture
def sample_attestation():
    """Sample attestation with policy configuration."""
    return {
        "policy": {
            "data": {
                "required": True,
                "vulnerabilities": {
                    "critical": {
                        "maximum": 0,
                        "exceptions": []
                    },
                    "high": {
                        "maximum": 5,
                        "exceptions": []
                    }
                }
            }
        },
        "result": "fail"
    }


@pytest.fixture
def empty_occurrence():
    """Occurrence with empty detail (edge case)."""
    return {
        "detail": {}
    }


@pytest.fixture
def display_mapper():
    """Import the display mapper module."""
    # Add mapper directory to path
    mappers_dir = Path("../../mappers")
    if mappers_dir.exists():
        sys.path.insert(0, str(mappers_dir))

    try:
        import display
        return display
    except ImportError as e:
        pytest.skip(f"Could not import display.py: {e}")


# ============================================================================
# Basic Functionality Tests
# ============================================================================

class TestBasicFunctionality:
    """Test basic mapper functionality."""

    def test_mapper_has_main_function(self, display_mapper):
        """Mapper must have a main() function."""
        assert hasattr(display_mapper, 'main'), "display.py must have a main() function"

    def test_main_accepts_three_parameters(self, display_mapper):
        """main() must accept occurrence, attestation, and context parameters."""
        import inspect
        sig = inspect.signature(display_mapper.main)
        params = list(sig.parameters.keys())

        assert len(params) == 3, "main() must accept exactly 3 parameters"
        assert params[0] == 'occurrence', "First parameter must be 'occurrence'"
        assert params[1] == 'attestation', "Second parameter must be 'attestation'"
        assert params[2] == 'context', "Third parameter must be 'context'"

    def test_main_returns_dict(self, display_mapper, sample_occurrence, sample_attestation):
        """main() must return a dictionary."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert isinstance(result, dict), "main() must return a dictionary"

    def test_main_does_not_raise_exception(self, display_mapper, sample_occurrence, sample_attestation):
        """main() should not raise exceptions with valid input."""
        try:
            display_mapper.main(sample_occurrence, sample_attestation, {})
        except Exception as e:
            pytest.fail(f"main() raised unexpected exception: {e}")


# ============================================================================
# Output Structure Tests
# ============================================================================

class TestOutputStructure:
    """Test that mapper returns expected structure."""

    def test_returns_description_field(self, display_mapper, sample_occurrence, sample_attestation):
        """Output must have a 'description' field."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert 'description' in result, "Output must contain 'description' field"

    def test_description_is_string(self, display_mapper, sample_occurrence, sample_attestation):
        """Description field must be a string."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert isinstance(result['description'], str), "'description' must be a string"

    def test_description_is_not_empty(self, display_mapper, sample_occurrence, sample_attestation):
        """Description should not be empty."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert len(result['description']) > 0, "'description' should not be empty"

    def test_returns_tag_field(self, display_mapper, sample_occurrence, sample_attestation):
        """Output must have a 'tag' field."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert 'tag' in result, "Output must contain 'tag' field"

    def test_tag_is_string(self, display_mapper, sample_occurrence, sample_attestation):
        """Tag field must be a string."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert isinstance(result['tag'], str), "'tag' must be a string"

    def test_has_required_fields(self, display_mapper, sample_occurrence, sample_attestation):
        """Output must have all required fields."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        required_fields = ['description', 'tag']
        for field in required_fields:
            assert field in result, f"Output must contain '{field}' field"


# ============================================================================
# Violations Structure Tests (Optional)
# ============================================================================

class TestViolationsStructure:
    """Test violations structure if mapper returns it."""

    def test_violations_structure_if_present(self, display_mapper, sample_occurrence, sample_attestation):
        """If violations are returned, they should have correct structure."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        if 'violations' in result:
            violations = result['violations']

            assert isinstance(violations, dict), "'violations' must be a dictionary"
            assert 'columns' in violations, "'violations' must have 'columns'"
            assert isinstance(violations['columns'], dict), "'columns' must be a dictionary"

            # Each column definition should have 'name' and 'type'
            for col_key, col_def in violations['columns'].items():
                assert isinstance(col_def, dict), f"Column '{col_key}' must be a dictionary"
                assert 'name' in col_def, f"Column '{col_key}' must have 'name'"
                assert 'type' in col_def, f"Column '{col_key}' must have 'type'"

                # Type should be one of the valid types
                valid_types = ['string', 'number', 'email', 'url']
                assert col_def['type'] in valid_types, \
                    f"Column '{col_key}' type must be one of {valid_types}, got '{col_def['type']}'"


# ============================================================================
# Edge Case Tests
# ============================================================================

class TestEdgeCases:
    """Test edge cases and error handling."""

    def test_handles_empty_occurrence(self, display_mapper, empty_occurrence, sample_attestation):
        """Mapper should handle empty occurrence."""
        try:
            result = display_mapper.main(empty_occurrence, sample_attestation, {})
            assert isinstance(result, dict)
            assert 'description' in result
            assert 'tag' in result
        except Exception as e:
            pytest.fail(f"Failed to handle empty occurrence: {e}")

    def test_handles_empty_attestation(self, display_mapper, sample_occurrence):
        """Mapper should handle empty attestation."""
        empty_attestation = {}

        try:
            result = display_mapper.main(sample_occurrence, empty_attestation, {})
            assert isinstance(result, dict)
            assert 'description' in result
            assert 'tag' in result
        except Exception as e:
            pytest.fail(f"Failed to handle empty attestation: {e}")

    def test_handles_missing_detail(self, display_mapper, sample_attestation):
        """Mapper should handle occurrence without detail."""
        occurrence_no_detail = {"asset": {"key": "test"}}

        try:
            result = display_mapper.main(occurrence_no_detail, sample_attestation, {})
            assert isinstance(result, dict)
        except Exception as e:
            pytest.fail(f"Failed to handle missing detail: {e}")

    def test_handles_missing_summary(self, display_mapper, sample_attestation):
        """Mapper should handle occurrence without summary in detail."""
        occurrence_no_summary = {
            "detail": {}
        }

        try:
            result = display_mapper.main(occurrence_no_summary, sample_attestation, {})
            assert isinstance(result, dict)
        except Exception as e:
            pytest.fail(f"Failed to handle missing summary: {e}")

    def test_handles_none_inputs(self, display_mapper):
        """Mapper should handle None inputs gracefully."""
        try:
            result = display_mapper.main(None, None, None)
            assert result is not None
        except (TypeError, AttributeError):
            # It's ok to fail with type error on None, but should be graceful
            pass

    def test_handles_missing_context(self, display_mapper, sample_occurrence, sample_attestation):
        """Mapper should handle empty/None context."""
        result1 = display_mapper.main(sample_occurrence, sample_attestation, {})
        assert isinstance(result1, dict)

        result2 = display_mapper.main(sample_occurrence, sample_attestation, None)
        assert isinstance(result2, dict)


# ============================================================================
# Tag Content Tests
# ============================================================================

class TestTagContent:
    """Test that tag contains meaningful information."""

    def test_tag_not_empty(self, display_mapper, sample_occurrence, sample_attestation):
        """Tag should not be empty."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert len(result['tag']) > 0, "'tag' should not be empty"

    def test_tag_contains_summary_info(self, display_mapper, sample_occurrence, sample_attestation):
        """Tag should contain summary information from occurrence."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})
        tag = result['tag']

        # Tag should reference some data from the occurrence
        # This is a soft check - tag should not be a generic message
        assert len(tag) > 5, "Tag should contain meaningful content"

    @pytest.mark.skip(reason="Customize based on your control")
    def test_tag_shows_critical_count(self, display_mapper, sample_attestation):
        """
        Example: For vulnerability scanner, tag should show critical count.

        Customize this test based on your control's tag format.
        """
        occurrence = {
            "detail": {
                "summary": {
                    "critical": 5,
                    "high": 10
                }
            }
        }

        result = display_mapper.main(occurrence, sample_attestation, {})
        tag = result['tag']

        # Check that tag contains the critical count
        assert '5' in tag, "Tag should show critical count"


# ============================================================================
# Description Content Tests
# ============================================================================

class TestDescriptionContent:
    """Test that description contains meaningful information."""

    def test_description_not_empty(self, display_mapper, sample_occurrence, sample_attestation):
        """Description should not be empty."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert len(result['description']) > 0, "'description' should not be empty"

    def test_description_is_informative(self, display_mapper, sample_occurrence, sample_attestation):
        """Description should be informative (reasonable length)."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})
        description = result['description']

        # Description should be at least a sentence
        assert len(description) > 20, "Description should be informative"

    def test_description_explains_control(self, display_mapper, sample_occurrence, sample_attestation):
        """Description should explain what the control does."""
        result = display_mapper.main(sample_occurrence, sample_attestation, {})
        description = result['description'].lower()

        # Description should contain keywords related to evaluation/policy/control
        keywords = ['policy', 'control', 'evaluate', 'check', 'validate', 'scan', 'test']
        has_keyword = any(keyword in description for keyword in keywords)

        assert has_keyword, "Description should explain what the control does"


# ============================================================================
# Consistency Tests
# ============================================================================

class TestConsistency:
    """Test that output is consistent across calls."""

    def test_consistent_output_for_same_input(self, display_mapper, sample_occurrence, sample_attestation):
        """Same input should produce same output."""
        result1 = display_mapper.main(sample_occurrence, sample_attestation, {})
        result2 = display_mapper.main(sample_occurrence, sample_attestation, {})

        assert result1 == result2, "Same input should produce same output"

    def test_description_does_not_change(self, display_mapper, sample_attestation):
        """Description should be consistent across different occurrences."""
        occ1 = {"detail": {"summary": {"total": 10}}}
        occ2 = {"detail": {"summary": {"total": 20}}}

        result1 = display_mapper.main(occ1, sample_attestation, {})
        result2 = display_mapper.main(occ2, sample_attestation, {})

        # Description should be the same (it describes the control, not the data)
        assert result1['description'] == result2['description'], \
            "Description should be consistent"


# ============================================================================
# Integration with Detail Mapper
# ============================================================================

class TestIntegrationWithDetail:
    """Test display mapper with output from detail mapper."""

    @pytest.fixture
    def detail_mapper(self):
        """Import detail mapper."""
        mappers_dir = Path("../../mappers")
        if mappers_dir.exists():
            sys.path.insert(0, str(mappers_dir))

        try:
            import detail
            return detail
        except ImportError:
            pytest.skip("Could not import detail.py")

    @pytest.fixture
    def test_payloads(self):
        """Load test payloads."""
        payloads_dir = Path("../../testing/payloads")
        if not payloads_dir.exists():
            pytest.skip("No test payloads found")

        payloads = []
        for json_file in payloads_dir.glob("*.json"):
            with open(json_file) as f:
                payloads.append(json.load(f))

        return payloads

    def test_display_works_with_detail_output(self, detail_mapper, display_mapper, test_payloads, sample_attestation):
        """Display mapper should work with detail mapper output."""
        for payload in test_payloads:
            # Run detail mapper first
            mapped_detail = detail_mapper.main(payload, {})

            # Create occurrence with mapped detail
            occurrence_with_detail = {
                **payload,
                "detail": mapped_detail
            }

            # Run display mapper
            try:
                result = display_mapper.main(occurrence_with_detail, sample_attestation, {})
                assert isinstance(result, dict)
                assert 'description' in result
                assert 'tag' in result
            except Exception as e:
                pytest.fail(f"Display mapper failed with detail output: {e}")


# ============================================================================
# Run Tests
# ============================================================================

if __name__ == '__main__':
    pytest.main([__file__, '-v'])

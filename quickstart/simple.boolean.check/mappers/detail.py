def main(occurrence, context):
    """
    The simplest possible mapper - just pass through the boolean value.

    Args:
        occurrence (dict): Raw occurrence data
        context (dict): Execution context

    Returns:
        dict: Contains the boolean value to check
    """
    # Extract the value from the occurrence
    detail = occurrence.get('detail', {})
    value = detail.get('check_passed', False)

    # Return it in a structure the rule expects
    return {
        'passed': value
    }

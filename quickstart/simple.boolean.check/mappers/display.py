def main(occurrence, attestation, context):
    """
    Format the control result for display in the UI.

    Args:
        occurrence (dict): Occurrence with mapped detail
        attestation (dict): Policy and evaluation results
        context (dict): Execution context

    Returns:
        dict: Display configuration
    """
    detail = occurrence.get('detail', {})
    passed = detail.get('passed', False)

    return {
        'description': 'A simple boolean check - the most minimal control possible',
        'tag': f'Value: {passed}'
    }

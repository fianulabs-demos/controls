# Troubleshooting Guide

This guide provides solutions to common issues you may encounter when developing, testing, and deploying Fianu Official Controls.

## Table of Contents

1. [Development Issues](#development-issues)
2. [Packaging Issues](#packaging-issues)
3. [Deployment Issues](#deployment-issues)
4. [Evaluation Issues](#evaluation-issues)
5. [Performance Issues](#performance-issues)
6. [Getting Help](#getting-help)

---

## Development Issues

### Control doesn't show up after deployment

**Symptom**: Control deploys successfully but doesn't appear in the Fianu dashboard.

**Possible Causes**:
1. Control was previously archived
2. Wrong environment/tenant
3. Permission issues

**Solutions**:
1. **Check if archived**: Query the API to see if control with same ID exists and is archived
2. **Regenerate ID**: If archived, create a new UUID for the `id` field in `spec.yaml`
   ```bash
   # Generate new UUID
   python3 -c "import uuid; print(uuid.uuid4())"
   # Or on macOS/Linux
   uuidgen
   ```
3. **Verify environment**: Ensure `FIANU_HOST` matches where you're looking
4. **Check permissions**: Verify your credentials have control creation rights

---

### YAML syntax errors

**Symptom**: Errors when parsing `spec.yaml`

**Common Issues**:
- Incorrect indentation (use 2 spaces, not tabs)
- Unquoted special characters (`:`, `#`, `-`, etc.)
- Missing quotes around version numbers
- Incorrect list syntax

**Solutions**:
1. **Validate YAML**:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('spec.yaml'))"
   ```

2. **Common fixes**:
   ```yaml
   # BAD - version should be string
   version: 1

   # GOOD
   version: '1'

   # BAD - description with colon needs quotes
   description: Status: Complete

   # GOOD
   description: "Status: Complete"
   ```

3. **Use a YAML linter**: Install `yamllint` for better validation
   ```bash
   pip install yamllint
   yamllint spec.yaml
   ```

---

### JSON syntax errors

**Symptom**: Errors when parsing `contents.json` or policy/occurrence files

**Common Issues**:
- Trailing commas
- Single quotes instead of double quotes
- Comments (JSON doesn't support comments)

**Solutions**:
1. **Validate JSON**:
   ```bash
   python3 -c "import json; json.load(open('contents.json'))"
   ```

2. **Common fixes**:
   ```json
   // BAD - trailing comma
   {
     "type": "control",
   }

   // GOOD
   {
     "type": "control"
   }

   // BAD - single quotes
   {'type': 'control'}

   // GOOD
   {"type": "control"}
   ```

3. **Use `jq` for validation**:
   ```bash
   cat contents.json | jq .
   ```

---

### Python mapper errors

**Symptom**: `detail.py` or `display.py` fails during execution

**Common Issues**:
- Missing null checks
- KeyError on missing fields
- Wrong function signature

**Solutions**:
1. **Always use `.get()` with defaults**:
   ```python
   # BAD - will fail if 'detail' missing
   status = occurrence['detail']['status']

   # GOOD - safe with defaults
   detail = occurrence.get('detail', {})
   status = detail.get('status', 'unknown')
   ```

2. **Check function signatures**:
   ```python
   # detail.py
   def main(occurrence, context):
       return {}

   # display.py
   def main(occurrence, attestation, context):
       return {}
   ```

3. **Test locally**:
   ```python
   python3 -c "
   import sys
   sys.path.insert(0, 'mappers')
   import detail
   import json

   occ = json.load(open('testing/payloads/occ_case_1.json'))
   result = detail.main(occ, {})
   print(json.dumps(result, indent=2))
   "
   ```

---

### Rego rule errors

**Symptom**: `rule.rego` fails compilation or evaluation

**Common Issues**:
- Missing `import future.keywords`
- Undefined defaults
- Syntax errors in comprehensions
- Wrong data references

**Solutions**:
1. **Always define defaults**:
   ```rego
   # Required at top of file
   default pass = false
   default fail = false
   default notFound = false
   default notRequired = false
   ```

2. **Import future keywords**:
   ```rego
   import future.keywords
   ```

3. **Test with OPA**:
   ```bash
   # Install OPA
   brew install opa  # macOS
   # or download from https://www.openpolicyagent.org/

   # Test rule
   opa eval -d rule/rule.rego \
            -i testing/payloads/occ_case_1.json \
            --data inputs/data/policy_case_1.json \
            "data.rule.pass"
   ```

4. **Common syntax issues**:
   ```rego
   # BAD - missing 'if'
   pass {
       input.detail.status == "success"
   }

   # GOOD
   pass if {
       input.detail.status == "success"
   }
   ```

---

## Packaging Issues

### `fianu package` command not found

**Symptom**: Shell can't find `fianu` command

**Solution**:
1. **Verify installation**:
   ```bash
   which fianu
   fianu --version
   ```

2. **Install Fianu CLI**: Follow installation guide at `https://docs.fianu.io/cli`

3. **Check PATH**: Ensure Fianu CLI is in your PATH
   ```bash
   echo $PATH
   ```

---

### Package fails with "contents.json not found"

**Symptom**: `fianu package` says `contents.json` doesn't exist

**Solutions**:
1. **Check file exists**:
   ```bash
   ls -la contents.json
   ```

2. **Verify you're in control directory**:
   ```bash
   pwd
   ls spec.yaml contents.json
   ```

3. **Check file permissions**:
   ```bash
   chmod 644 contents.json
   ```

---

### Package fails with "referenced file not found"

**Symptom**: `fianu package` can't find file referenced in `contents.json`

**Solutions**:
1. **Verify all files exist**:
   ```bash
   test -f mappers/detail.py || echo "Missing detail.py"
   test -f mappers/display.py || echo "Missing display.py"
   test -f rule/rule.rego || echo "Missing rule.rego"
   ```

2. **Check paths in `contents.json` are relative**:
   ```json
   {
     "detail": {
       "ref": "detail.py",              // GOOD - relative
       "workingDirectory": "mappers"
     }
   }
   ```

3. **Verify working directories are correct**:
   - `detail.py` and `display.py` should be in `mappers/`
   - `rule.rego` should be in `rule/`

---

## Deployment Issues

### Authentication failures

**Symptom**: `fianu apply` fails with authentication error

**Solutions**:
1. **Verify credentials are set**:
   ```bash
   echo $FIANU_CLIENT_ID
   echo $FIANU_CLIENT_SECRET
   echo $FIANU_HOST
   ```

2. **Check credentials are correct**: Verify in Fianu dashboard under API settings

3. **Test authentication**:
   ```bash
   fianu auth test
   ```

---

### Control deployment fails with schema errors

**Symptom**: `fianu apply` rejects control due to schema validation

**Common Issues**:
- Invalid UUIDs
- Missing required fields
- Wrong data types

**Solutions**:
1. **Run clean_spec.py** (if you have access to official-controls repo):
   ```bash
   python3 scripts/clean_spec.py
   ```

2. **Validate UUIDs**:
   ```bash
   python3 -c "
   import yaml
   import uuid

   spec = yaml.safe_load(open('spec.yaml'))
   try:
       uuid.UUID(spec['id'])
       print('✓ Valid UUID')
   except ValueError:
       print('✗ Invalid UUID')
   "
   ```

3. **Check required fields**:
   - `id`, `displayKey`, `version`, `path`, `name`, `fullName`, `description`
   - `measures`, `results`, `scope`, `relations`, `assets`
   - `isOfficial`, `evidenceSubmissions`, `manualAttestations`

---

### Control deploys but never evaluates

**Symptom**: Control shows in dashboard but no evaluations occur

**Possible Causes**:
1. No occurrences being produced
2. Wrong occurrence path in relations
3. Asset type mismatch

**Solutions**:
1. **Verify occurrence path**: Check that `relations[].path` matches actual occurrence path

2. **Check occurrence is being produced**:
   - Look for occurrences in Fianu dashboard
   - Verify integration is running
   - Check occurrence path matches control subscription

3. **Verify asset types match**:
   ```yaml
   # Control must target same asset type as occurrence
   assets:
   - type: repository
     targetAssetTypeUuid: 681da6ae-edbc-4587-8777-1503602abd4a
   ```

---

## Evaluation Issues

### Control always fails

**Symptom**: Control evaluates but always returns `fail`

**Solutions**:
1. **Check rule logic**:
   ```rego
   # Add logging
   pass if {
       log(sprintf("input.detail: %v", [input.detail]))
       log(sprintf("data: %v", [data]))
       # ... rest of logic
   }
   ```

2. **Verify mapper output matches rule expectations**:
   - Test mapper locally
   - Check `input.detail` structure in rule

3. **Check policy configuration**:
   - Ensure policy values are reasonable
   - Verify data types match (number vs string)

---

### Control always shows "notFound"

**Symptom**: Control evaluates to `notFound` instead of pass/fail

**Possible Causes**:
1. No occurrence data
2. Mapper returns empty/null
3. Wrong occurrence path

**Solutions**:
1. **Check occurrence exists**: Look in Fianu dashboard for occurrences

2. **Verify mapper doesn't return null**:
   ```python
   def main(occurrence, context):
       detail = occurrence.get('detail', {})

       # Always return something, even if empty
       return {
           'status': detail.get('status', 'unknown'),
           'items': []
       }
   ```

3. **Check relation path**: Ensure `relations[].path` matches occurrence

---

### Violations not showing details

**Symptom**: Control fails but violations are empty or missing details

**Solution**: Ensure you're calling `fianu.record_violation()` in Rego:

```rego
pass if {
    violations := count([
        v |
        v := input.detail.items[_]
        check := evaluate_item(v)
        fianu.record_violation(check, v)  // ← Must call this
        not check
    ])

    violations == 0
}
```

---

### Performance Issues

### Control evaluation is slow

**Symptom**: Control takes a long time to evaluate

**Common Causes**:
1. Complex Rego logic
2. Large datasets
3. Inefficient comprehensions

**Solutions**:
1. **Simplify Rego rules**:
   - Avoid nested loops
   - Use built-in functions
   - Pre-filter data in mapper

2. **Optimize mapper**:
   ```python
   # BAD - processes everything
   def main(occurrence, context):
       items = occurrence['detail']['items']
       return {'items': items}  # Could be thousands

   # GOOD - pre-filter and summarize
   def main(occurrence, context):
       items = occurrence['detail']['items']

       # Filter to only failures
       failures = [i for i in items if i['status'] == 'failed']

       return {
           'summary': {'failed': len(failures), 'total': len(items)},
           'failures': failures[:100]  # Limit to 100
       }
   ```

3. **Use rule profiling**:
   ```bash
   opa eval --profile -d rule/rule.rego "data.rule.pass"
   ```

---

## Getting Help

### Self-Service Resources

1. **[FAQ](faq/)** - Common questions and answers
2. **[Examples](examples/)** - Working control examples
3. **[Reference](reference/)** - Complete documentation
4. **[Best Practices](best-practices/)** - Design guidelines

### Community Support

1. **GitHub Issues**: Report bugs and request features
   - https://github.com/fianulabs/official-controls/issues

2. **GitHub Discussions**: Ask questions and share solutions
   - https://github.com/fianulabs/official-controls/discussions

3. **Documentation**: Official Fianu documentation
   - https://docs.fianu.io

### Enterprise Support

Contact your Fianu representative for:
- Priority support
- Custom integration assistance
- Training and workshops
- Architecture reviews

---

## Debug Checklist

When troubleshooting, check:

- [ ] All required files exist and have correct permissions
- [ ] YAML/JSON syntax is valid
- [ ] UUIDs are properly formatted
- [ ] Environment variables are set correctly
- [ ] Fianu CLI is installed and up to date
- [ ] Control is deployed to correct environment
- [ ] Occurrence path matches relation subscription
- [ ] Asset types match between control and occurrence
- [ ] Mapper returns expected structure
- [ ] Rule has all required defaults defined
- [ ] Policy configuration is valid JSON
- [ ] Test data is realistic and complete

---

## Quick Fixes

```bash
# Validate all files
python3 -c "import yaml; yaml.safe_load(open('spec.yaml'))" && echo "✓ spec.yaml valid"
python3 -c "import json; json.load(open('contents.json'))" && echo "✓ contents.json valid"

# Generate new UUID
python3 -c "import uuid; print(uuid.uuid4())"

# Test mapper locally
python3 -c "
import sys, json
sys.path.insert(0, 'mappers')
import detail
occ = json.load(open('testing/payloads/occ_case_1.json'))
print(json.dumps(detail.main(occ, {}), indent=2))
"

# Repackage and deploy
fianu package --path . -o control.tgz && fianu apply --path control.tgz
```

---

**Still stuck?** → [Open a GitHub Issue](https://github.com/fianulabs/official-controls/issues)

**Need concepts review?** → [Read Core Concepts](CONCEPTS.md)

**Want to start over?** → [Getting Started Guide](GETTING_STARTED.md)

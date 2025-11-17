# Quickstart Walkthrough: Simple Boolean Check

This is the **absolute simplest** Fianu control possible. It checks if a boolean value is `true`. That's it!

**Time to complete**: 5 minutes

---

## Why Start Here?

This example strips away all complexity so you can understand:
- The basic file structure every control needs
- How data flows through the system
- What each component does

Once you understand this, you'll be ready for more complex controls.

---

## What This Control Does

```
Input: { "check_passed": true }
↓
Mapper: Extract the boolean value
↓
Rule: Check if value == true
↓
Result: PASS or FAIL
```

---

## File-by-File Explanation

### 1. spec.yaml (Metadata)

```yaml
path: example.simple.boolean
name: Simple Boolean Check
description: The simplest possible control...

measures:
- name: required
  type: metric
  value: bool
```

**What it defines**:
- `path`: Unique name for your control
- `name`: Short display name
- `description`: What the control does
- `measures`: Policy configuration (just "required" here - is this check mandatory?)

**Key insight**: The `measures` section defines what users can configure. Here, users can only set whether the control is required or optional.

### 2. contents.json (Component Links)

```json
{
  "detail": {
    "ref": "detail.py",
    "workingDirectory": "mappers"
  },
  "rule": {
    "engine": "opa",
    "ref": "rule.rego",
    "workingDirectory": "rule"
  },
  ...
}
```

**What it does**: Tells Fianu where to find each component:
- Mappers are in `mappers/` directory
- Rule is in `rule/` directory
- Test data is in `inputs/` and `testing/` directories

**Key insight**: This is like a table of contents for your control.

### 3. mappers/detail.py (Data Extraction)

```python
def main(occurrence, context):
    detail = occurrence.get('detail', {})
    value = detail.get('check_passed', False)

    return {
        'passed': value
    }
```

**Line by line**:
1. `occurrence.get('detail', {})` - Get the `detail` section from incoming data (safe, won't crash if missing)
2. `detail.get('check_passed', False)` - Extract the boolean value (default to False if missing)
3. `return {'passed': value}` - Return it in a clean structure

**Key insight**: This transforms messy real-world data into clean, structured data the rule can easily evaluate.

### 4. mappers/display.py (UI Formatting)

```python
def main(occurrence, attestation, context):
    detail = occurrence.get('detail', {})
    passed = detail.get('passed', False)

    return {
        'description': 'A simple boolean check...',
        'tag': f'Value: {passed}'
    }
```

**What it does**: Formats how the result appears in the Fianu dashboard.

**Key insight**: Separate from the rule evaluation - this is purely for display.

### 5. rule/rule.rego (Policy Evaluation)

```rego
package rule

default pass = false
default notRequired = false

import future.keywords

pass if {
    input.detail.passed == true
}

notRequired if {
    not pass
    data.required == false
}
```

**Line by line**:
1. `default pass = false` - By default, control fails
2. `pass if { input.detail.passed == true }` - Control passes only if value is true
3. `notRequired if { not pass; data.required == false }` - If it fails but policy says optional, mark as "not required"

**Key insight**:
- `input.detail` comes from the detail mapper
- `data.required` comes from the policy configuration
- The rule combines both to make a decision

### 6. inputs/data/policy_case_1.json (Policy Config)

```json
{
  "required": true
}
```

**What it is**: A test policy configuration. Users would set this value in the Fianu UI.

**Key insight**: This is what users configure - the "rules" of your control.

### 7. testing/payloads/occ_case_1.json (Test Data)

```json
{
  ...
  "detail": {
    "check_passed": true,
    "message": "All checks passed successfully"
  }
}
```

**What it is**: Sample data from an integration. In the real world, this would come from an actual system (Snyk, JUnit, Jira, etc.).

**Key insight**: This is the raw input your control receives. The `detail` section contains the actual data to evaluate.

---

## Data Flow

Let's trace one evaluation from start to finish:

### Step 1: Occurrence Arrives
```json
{
  "detail": {
    "check_passed": true
  }
}
```

### Step 2: detail.py Transforms It
```python
# Input: occurrence
# Output:
{
  "passed": true
}
```

### Step 3: rule.rego Evaluates It
```rego
# Input: { "detail": { "passed": true } }
# Policy: { "required": true }
# Logic: input.detail.passed == true → TRUE
# Output: PASS
```

### Step 4: display.py Formats It
```python
# Output:
{
  "description": "A simple boolean check...",
  "tag": "Value: True"
}
```

### Step 5: Result Recorded
```
Control: example.simple.boolean
Status: PASS
Tag: Value: True
```

---

## Try It Yourself

### 1. Navigate to the control
```bash
cd examples/quickstart/simple.boolean.check
```

### 2. Test the mapper locally
```bash
python3 << 'EOF'
import sys
import json
sys.path.insert(0, 'mappers')
import detail

# Load test occurrence
occ = json.load(open('testing/payloads/occ_case_1.json'))

# Run mapper
result = detail.main(occ, {})

# Print result
print("Mapper output:", json.dumps(result, indent=2))
EOF
```

Expected output:
```json
{
  "passed": true
}
```

### 3. Change the test data
Edit `testing/payloads/occ_case_1.json` and change:
```json
"check_passed": true
```
to:
```json
"check_passed": false
```

Now run the mapper again - you should see `"passed": false`.

### 4. Package and deploy
```bash
fianu package --path . -o simple-boolean.tgz
fianu apply --path simple-boolean.tgz
```

---

## Experiment!

Try modifying the control:

### Change 1: Add a description field
In `mappers/detail.py`:
```python
return {
    'passed': value,
    'description': detail.get('message', 'No message provided')
}
```

### Change 2: Show description in display
In `mappers/display.py`:
```python
description = detail.get('description', '')
return {
    'description': description,
    'tag': f'Value: {passed}'
}
```

### Change 3: Add logging to the rule
In `rule/rule.rego`:
```rego
pass if {
    log(sprintf("Checking if passed: %v", [input.detail.passed]))
    input.detail.passed == true
}
```

---

## What's Next?

Now that you understand the basics:

1. **[Tutorial 1: Hello World](../tutorials/01-hello-world/)** - Build on this foundation
2. **[Getting Started Guide](../GETTING_STARTED.md)** - Create a more realistic control
3. **[Templates](../templates/)** - Use pre-built scaffolding

---

## Key Takeaways

✅ Every control has 5 core files: `spec.yaml`, `contents.json`, `detail.py`, `display.py`, `rule.rego`

✅ Data flows: Occurrence → Mapper → Rule → Display → Result

✅ Mappers transform data (Python)

✅ Rules evaluate policy (Rego)

✅ `input.*` in Rego comes from mappers

✅ `data.*` in Rego comes from policy configuration

✅ Always handle missing data gracefully (use `.get()`)

✅ Always define default result states in Rego

---

**Questions?** → Check the [FAQ](../faq/)

**Issues?** → See [Troubleshooting](../TROUBLESHOOTING.md)

**Ready for more?** → [Continue to Tutorials](../tutorials/)

# Core Concepts

This guide explains the fundamental concepts behind Fianu Official Controls, their architecture, and how they work together to enforce compliance policies.

## Table of Contents

1. [What are Official Controls?](#what-are-official-controls)
2. [Architecture Overview](#architecture-overview)
3. [Control Lifecycle](#control-lifecycle)
4. [Data Flow](#data-flow)
5. [Key Components](#key-components)
6. [Result States](#result-states)
7. [Asset Types & Targeting](#asset-types--targeting)
8. [Terminology](#terminology)

---

## What are Official Controls?

**Fianu Official Controls** are policy-driven compliance checks that evaluate your software development lifecycle. They act as programmable quality gates that can enforce standards across your entire SDLC.

### Key Characteristics

- **Policy-Driven**: Users configure policy thresholds, not developers
- **Programmable**: Full logic control using Python and Rego
- **Data-Agnostic**: Can evaluate any JSON-structured data
- **Reusable**: Once deployed, can be configured for multiple assets
- **Auditable**: All evaluations are logged with full context

### Use Cases

Controls can evaluate:
- Security scan results (SAST, DAST, SCA, container scanning)
- Test execution (unit, integration, functional, coverage)
- Code review practices (PR approvals, Jira associations)
- Build pipeline status (success/failure, duration)
- Compliance requirements (SBOM, signatures, licenses)
- Custom business logic (SLAs, deployment frequency, etc.)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Fianu Platform                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Integration Layer                       │
│  (Snyk, GitHub, Jira, JUnit, Custom APIs, etc.)            │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Produces Occurrence
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Official Control Engine                   │
│                                                               │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   │
│  │    Mapper    │──>│     Rule     │──>│   Display    │   │
│  │ (detail.py)  │   │ (rule.rego)  │   │ (display.py) │   │
│  └──────────────┘   └──────────────┘   └──────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Produces Result
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Fianu Dashboard                         │
│              (Results, Violations, Audit Trail)             │
└─────────────────────────────────────────────────────────────┘
```

### Components

1. **Integration Layer**: Collects data from external systems
2. **Occurrence**: Raw data from integration
3. **Detail Mapper**: Transforms raw data into structured format
4. **Rule Engine**: Evaluates data against policy using OPA/Rego
5. **Display Mapper**: Formats results for UI presentation
6. **Result**: Final compliance status (pass, fail, etc.)

---

## Control Lifecycle

### 1. Development Phase

```
Developer creates control → Tests locally → Packages → Deploys
```

- Write mappers (Python)
- Write rules (Rego)
- Create test data
- Validate structure
- Package with `fianu package`
- Deploy with `fianu apply`

### 2. Configuration Phase

```
User configures policy → Assigns to assets → Control becomes active
```

- User defines policy thresholds in Fianu UI
- Assigns control to repositories, modules, or artifacts
- Control starts listening for occurrences

### 3. Evaluation Phase

```
Event occurs → Occurrence created → Control evaluates → Result recorded
```

- Integration produces occurrence (e.g., Snyk scan completes)
- Fianu triggers control evaluation
- Mappers transform data
- Rule evaluates against policy
- Result stored with violations (if any)

### 4. Reporting Phase

```
Results visible in dashboard → Audit trail available → Actions taken
```

- Users see pass/fail status
- Violations listed with details
- Historical trends tracked
- Compliance reports generated

---

## Data Flow

### Detailed Flow Diagram

```
┌──────────────────┐
│   Integration    │
│   (e.g., Snyk)   │
└────────┬─────────┘
         │
         │ 1. Produces raw data
         ▼
┌──────────────────┐
│   Occurrence     │ <-- Raw JSON data from integration
│   {              │
│     "detail": {  │
│       ...        │
│     }            │
│   }              │
└────────┬─────────┘
         │
         │ 2. Passed to detail mapper
         ▼
┌──────────────────┐
│   detail.py      │
│   def main(occ,  │
│            ctx): │
│     return {     │
│       "summary": │
│       "items":   │
│     }            │
└────────┬─────────┘
         │
         │ 3. Transformed data + Policy
         ▼
┌──────────────────┐
│   rule.rego      │
│   pass if {      │
│     input.detail │
│     data.policy  │
│   }              │
└────────┬─────────┘
         │
         │ 4. Evaluation result + data
         ▼
┌──────────────────┐
│   display.py     │
│   def main(occ,  │
│            att,  │
│            ctx): │
│     return {     │
│       "tag":     │
│       "desc":    │
│     }            │
└────────┬─────────┘
         │
         │ 5. Final result
         ▼
┌──────────────────┐
│     Result       │
│   - Status       │
│   - Violations   │
│   - Display      │
└──────────────────┘
```

### Data Transformation Example

**Input (Occurrence):**
```json
{
  "detail": {
    "scan": {
      "runs": [{
        "results": [
          {
            "level": "error",
            "ruleId": "CVE-2023-1234"
          }
        ]
      }]
    }
  }
}
```

**After detail.py:**
```json
{
  "summary": {
    "critical": 0,
    "high": 1
  },
  "vulnerabilities": [
    {
      "level": "high",
      "id": "CVE-2023-1234"
    }
  ]
}
```

**Policy (data):**
```json
{
  "required": true,
  "vulnerabilities": {
    "critical": {
      "maximum": 0
    },
    "high": {
      "maximum": 0
    }
  }
}
```

**Rule Evaluation:**
```rego
pass if {
    input.detail.summary.critical <= data.vulnerabilities.critical.maximum
    input.detail.summary.high <= data.vulnerabilities.high.maximum
}
# Result: FAIL (1 high > 0 maximum)
```

**After display.py:**
```json
{
  "description": "SAST scan results",
  "tag": "Critical (0), High (1)"
}
```

---

## Key Components

### 1. spec.yaml

**Purpose**: Defines control metadata and policy structure

**Key sections**:
- `measures`: Policy configuration schema (what users configure)
- `relations`: Data source subscriptions (where data comes from)
- `assets`: Asset types this control applies to
- `results`: Possible evaluation outcomes

**Example**:
```yaml
measures:
- name: required
  type: metric
  value: bool
- name: vulnerabilities
  type: section
  children:
  - name: critical
    children:
    - name: maximum
      type: metric
      value: number
```

### 2. contents.json

**Purpose**: References all control components

**Key sections**:
- `data`: Policy test cases
- `detail`: Detail mapper reference
- `display`: Display mapper reference
- `rule`: Rule engine and reference
- `spec`: Spec and test occurrence references

### 3. detail.py (Mapper)

**Purpose**: Transform raw occurrence data

**Signature**:
```python
def main(occurrence, context):
    """
    Args:
        occurrence (dict): Raw occurrence data
        context (dict): Execution context

    Returns:
        dict: Structured data for rule evaluation
    """
    return {
        'summary': {...},
        'items': [...]
    }
```

**Best practices**:
- Handle missing/null values gracefully
- Return consistent structure
- Create summaries for aggregation
- Don't evaluate policy (that's the rule's job)

### 4. rule.rego (Rule)

**Purpose**: Evaluate data against policy

**Structure**:
```rego
package rule

default pass = false
default notRequired = false

import future.keywords

pass if {
    # Evaluation logic using:
    # - input.detail (from mapper)
    # - data.* (from policy)
}

notRequired if {
    not pass
    data.required == false
}
```

**Key concepts**:
- `input.*` = Transformed occurrence data
- `data.*` = Policy configuration
- `fianu.record_violation()` = Track violations
- Always define defaults

### 5. display.py (Mapper)

**Purpose**: Format results for UI

**Signature**:
```python
def main(occurrence, attestation, context):
    """
    Args:
        occurrence (dict): Occurrence with mapped detail
        attestation (dict): Policy and evaluation results
        context (dict): Execution context

    Returns:
        dict: Display configuration
    """
    return {
        'description': 'Control description',
        'tag': 'Summary info'
    }
```

---

## Result States

Controls can produce six result states:

| State | Meaning | When to Use |
|-------|---------|-------------|
| `pass` | Policy compliant | Evaluation succeeded |
| `fail` | Policy violation | Evaluation failed |
| `notFound` | No data available | Occurrence not found |
| `notRequired` | Policy optional | Failed but marked optional |
| `inProgress` | Still evaluating | Long-running evaluations |
| `warn` | Advisory only | Information, not failure |

### Result Configuration

In `spec.yaml`:
```yaml
results:
  pass: true
  fail: true
  notFound: true
  notRequired: true
  inProgress: false  # Most controls don't need this
  warn: false         # Rarely used
```

### Common Patterns

**Standard pattern** (most controls):
```rego
pass if {
    # evaluation logic
}

notRequired if {
    not pass
    data.required == false
}
```

**With in-progress** (long-running):
```rego
inProgress if {
    input.detail.status == "pending"
}

pass if {
    input.detail.status == "complete"
    # ... validation
}
```

---

## Asset Types & Targeting

### Asset Hierarchy

```
Line of Business (LOB)
└── Application
    └── Repository / Module / Artifact
        └── Commit / Tag / Version
```

### Common Asset Types

| Type | UUID | Description |
|------|------|-------------|
| Repository | `681da6ae-edbc-4587-8777-1503602abd4a` | Git repositories |
| Module | `840b4288-375c-43e3-93d1-b75bef079270` | Code modules/packages |
| Artifact | `a1d9bdc6-a29c-4247-8b1e-c8bd5fea1b55` | Built artifacts |

### Series Types

| Series | Code | Description |
|--------|------|-------------|
| Commit | `2112` | Git commits |
| Tag | `2113` | Git tags/releases |

### Scope

Controls operate at different scopes:

```yaml
scope: commit  # Most common
# OR
scope: tag
scope: artifact
scope: repository
```

**Scope determines**: At what level the control evaluates (per commit, per tag, etc.)

---

## Terminology

### Core Terms

- **Control**: A policy-driven compliance check
- **Occurrence**: Raw data from an integration
- **Policy**: User-configured thresholds and rules
- **Attestation**: The evaluation result of a control
- **Violation**: A specific policy breach with details
- **Measure**: A configurable policy parameter
- **Relation**: A data source subscription

### Component Terms

- **Mapper**: Python function that transforms data
- **Rule**: Rego policy evaluation logic
- **Detail Mapper**: Transforms occurrence → structured data
- **Display Mapper**: Formats results for UI

### Policy Terms

- **Metric**: A single policy value (bool, number, string, array)
- **Section**: A grouping container for metrics
- **Exception**: An exclusion from policy enforcement
- **Threshold**: A minimum or maximum limit

### Integration Terms

- **Plugin**: A Fianu integration type
- **Producer**: The system that creates occurrences
- **Subscription**: A control's data source registration
- **Collection**: A grouping of related data

### Evaluation Terms

- **Pass**: Control succeeded
- **Fail**: Control failed
- **NotFound**: No data to evaluate
- **NotRequired**: Control marked optional
- **InProgress**: Evaluation pending
- **Violation**: A recorded policy breach

---

## Next Steps

Now that you understand the concepts:

- **[Create your first control](GETTING_STARTED.md)** - Hands-on tutorial
- **[Explore examples](examples/)** - See complete controls
- **[Reference documentation](reference/)** - Deep dive into schemas
- **[Common patterns](patterns/)** - Reusable techniques

---

## Further Reading

- [Architecture Deep Dive](reference/architecture/) - Detailed system diagrams
- [Data Flow](reference/architecture/data-flow.md) - Trace data through system
- [Component Reference](reference/components/) - Detailed component docs
- [Best Practices](best-practices/) - Writing quality controls

---

**Ready to build?** → [Getting Started Guide](GETTING_STARTED.md)

**Need specifics?** → [Reference Documentation](reference/)

**Want examples?** → [Browse Examples](examples/)

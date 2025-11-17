# spec.yaml Reference

Complete field-by-field reference for the control specification file.

## Table of Contents

- [Overview](#overview)
- [Top-Level Fields](#top-level-fields)
- [Measures](#measures)
- [Results](#results)
- [Relations](#relations)
- [Assets](#assets)
- [Complete Example](#complete-example)
- [Validation Rules](#validation-rules)
- [Common Patterns](#common-patterns)

---

## Overview

The `spec.yaml` file is the core specification for a control. It defines:
- **Metadata**: ID, name, description
- **Policy structure**: Measures users can configure
- **Data sources**: Relations to occurrence data
- **Target assets**: What the control applies to
- **Result states**: Which outcomes are supported

## Top-Level Fields

### `id`
**Type**: `string` (UUID)
**Required**: Yes
**Description**: Unique identifier for the control

```yaml
id: 09c27275-3aaa-4530-bb62-07dc02d3b63c
```

**Rules**:
- Must be a valid UUID v4
- Must be globally unique
- Never reuse IDs from archived controls
- Generate with `uuidgen` command

---

### `displayKey`
**Type**: `string`
**Required**: Yes
**Description**: Short uppercase identifier shown in UI

```yaml
displayKey: SNYK
```

**Rules**:
- 3-6 uppercase letters
- No spaces or special characters
- Should be recognizable abbreviation
- Examples: `SNYK`, `CKMX`, `WIZ`, `GLAB`, `JUNIT`

---

### `version`
**Type**: `string`
**Required**: Yes
**Description**: Control version number

```yaml
version: '1'
```

**Rules**:
- Must be a string (not number)
- Usually starts at '1'
- Increment for breaking changes
- Format: `'1'`, `'2'`, `'3'`, etc.

---

### `roles`
**Type**: `array`
**Required**: Yes
**Description**: Access control roles

```yaml
roles: []
```

**Rules**:
- Empty array for official controls
- May contain role IDs for custom controls

---

### `path`
**Type**: `string`
**Required**: Yes
**Description**: Dot-notation path identifier

```yaml
path: snyk.sast.vulnerabilities
```

**Rules**:
- Lowercase only
- Dot-separated segments
- Should match directory name
- No special characters except dots
- Examples: `ci.commit.history`, `testing.unit.junit`

---

### `name`
**Type**: `string`
**Required**: Yes
**Description**: Short display name

```yaml
name: Snyk SAST
```

**Rules**:
- Concise (3-6 words)
- Shown in lists and menus
- Title case

---

### `fullName`
**Type**: `string`
**Required**: Yes
**Description**: Complete descriptive name

```yaml
fullName: Snyk Static Application Security Testing (SAST)
```

**Rules**:
- More descriptive than `name`
- Include acronym expansions
- Shown in detail views

---

### `description`
**Type**: `string` (multiline)
**Required**: Yes
**Description**: Detailed explanation of what the control evaluates

```yaml
description: |
  This control evaluates Snyk SAST scan results against policy-defined
  thresholds for vulnerability severity levels (critical, high, medium, low).

  The policy allows configuration of maximum allowed vulnerabilities per
  severity level, with support for exceptions (specific CVE/CWE exclusions)
  and location exclusions (file path patterns to ignore).
```

**Rules**:
- Explain what data source is used
- Describe what is evaluated
- List policy options available
- Use multiline format with `|`

---

### `documentation`
**Type**: `array` of `{title, url}` objects
**Required**: No
**Description**: External documentation links

```yaml
documentation:
  - title: Snyk Documentation
    url: https://docs.snyk.io/
  - title: SARIF Format Specification
    url: https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html
```

---

### `scope`
**Type**: `string`
**Required**: Yes
**Description**: Evaluation scope/level

```yaml
scope: commit
```

**Valid Values**:
- `commit` - Evaluate per commit
- `tag` - Evaluate per tag
- `artifact` - Evaluate per artifact
- `repository` - Evaluate per repository

**Most Common**: `commit`

---

### `retries`
**Type**: `boolean`
**Required**: Yes
**Description**: Whether control supports retry logic

```yaml
retries: false
```

**Rules**:
- Usually `false` for official controls
- Set to `true` if control can be retried on transient failures

---

### `isOfficial`
**Type**: `boolean`
**Required**: Yes
**Description**: Whether this is an official control

```yaml
isOfficial: true
```

**Rules**:
- Always `true` for official controls
- `false` for custom/tenant-specific controls

---

### `evidenceSubmissions`
**Type**: `boolean`
**Required**: Yes
**Description**: Whether control accepts manual evidence

```yaml
evidenceSubmissions: false
```

**Rules**:
- Always `false` for official controls

---

### `manualAttestations`
**Type**: `boolean`
**Required**: Yes
**Description**: Whether control accepts manual attestations

```yaml
manualAttestations: false
```

**Rules**:
- Always `false` for official controls

---

## Measures

Measures define the policy structure users configure. Two types exist:
1. **Metric** - Actual policy values
2. **Section** - Grouping containers

### Measure Object Structure

```yaml
- name: <measure_name>
  type: <metric|section>
  value: <value_type|null>
  node_id: <uuid>
  description: null
  lineItemException:
    enabled: false
    type: null
    expiration:
      required: false
  children: []
```

### Field Definitions

#### `name`
**Type**: `string`
**Required**: Yes
**Description**: Measure identifier

**Rules**:
- Lowercase with underscores
- No spaces
- Examples: `required`, `maximum`, `exceptions`, `allowed_issuetypes`

---

#### `type`
**Type**: `string`
**Required**: Yes
**Description**: Measure type

**Valid Values**:
- `metric` - Actual policy value
- `section` - Grouping container

---

#### `value`
**Type**: `string|null`
**Required**: Yes
**Description**: Data type for metrics, null for sections

**Valid Values for Metrics**:
- `bool` - Boolean (true/false)
- `number` - Numeric value
- `string` - Text value
- `array.string` - Array of strings

**For Sections**: `null`

---

#### `node_id`
**Type**: `string` (UUID)
**Required**: Yes
**Description**: Unique identifier for this measure

**Rules**:
- Must be unique within control
- Generate new UUID for each measure
- Never reuse from other controls

---

#### `description`
**Type**: `string|null`
**Required**: Yes
**Description**: User-facing description (currently unused)

**Rules**:
- Always `null` in current implementation
- Reserved for future use

---

#### `lineItemException`
**Type**: `object`
**Required**: Yes
**Description**: Exception configuration (currently unused)

**Standard Value**:
```yaml
lineItemException:
  enabled: false
  type: null
  expiration:
    required: false
```

**Rules**:
- Always use these exact values
- Reserved for future exception features

---

#### `children`
**Type**: `array`
**Required**: Yes
**Description**: Child measures (for sections)

**Rules**:
- Empty array `[]` for metrics
- Contains child measure objects for sections
- Can nest sections within sections

---

### Common Measure Patterns

**Boolean Flag (required)**:
```yaml
- name: required
  type: metric
  value: bool
  node_id: <uuid>
  description: null
  lineItemException:
    enabled: false
    type: null
    expiration:
      required: false
  children: []
```

**Severity Levels (vulnerability scanning)**:
```yaml
- name: vulnerabilities
  type: section
  value: null
  node_id: <uuid>
  description: null
  lineItemException:
    enabled: false
    type: null
    expiration:
      required: false
  children:
  - name: critical
    type: section
    value: null
    node_id: <uuid>
    description: null
    lineItemException:
      enabled: false
      type: null
      expiration:
        required: false
    children:
    - name: maximum
      type: metric
      value: number
      node_id: <uuid>
      description: null
      lineItemException:
        enabled: false
        type: null
        expiration:
          required: false
      children: []
    - name: exceptions
      type: metric
      value: array.string
      node_id: <uuid>
      description: null
      lineItemException:
        enabled: false
        type: null
        expiration:
          required: false
      children: []
  # Repeat for: high, medium, low
```

**Test Thresholds**:
```yaml
- name: tests
  type: section
  value: null
  node_id: <uuid>
  children:
  - name: failed
    type: section
    value: null
    node_id: <uuid>
    children:
    - name: maximum
      type: metric
      value: number
      node_id: <uuid>
    - name: exceptions
      type: metric
      value: array.string
      node_id: <uuid>
```

**Association Configuration**:
```yaml
- name: jira
  type: section
  value: null
  node_id: <uuid>
  children:
  - name: allowed_issuetypes
    type: metric
    value: array.string
    node_id: <uuid>
  - name: not_allowed_statuses
    type: metric
    value: array.string
    node_id: <uuid>
```

---

## Results

Defines which result states the control supports.

### Structure

```yaml
results:
  fail: <boolean>
  inProgress: <boolean>
  notFound: <boolean>
  notRequired: <boolean>
  pass: <boolean>
  warn: <boolean>
```

### Field Definitions

#### `pass`
**Type**: `boolean`
**Description**: Control can pass

**Rules**:
- Usually `true`
- Set to `false` if control only detects violations

---

#### `fail`
**Type**: `boolean`
**Description**: Control can fail

**Rules**:
- Usually `true`
- Set to `false` if control is informational only

---

#### `notFound`
**Type**: `boolean`
**Description**: Control can be not found (no data)

**Rules**:
- `true` if control depends on external data
- `false` if control always has data

---

#### `notRequired`
**Type**: `boolean`
**Description**: Control can be marked not required by policy

**Rules**:
- Usually `true`
- Allows `required: false` in policy

---

#### `inProgress`
**Type**: `boolean`
**Description**: Control can be in progress

**Rules**:
- Usually `false`
- `true` for controls with async operations

---

#### `warn`
**Type**: `boolean`
**Description**: Control can warn

**Rules**:
- Rarely used
- Usually `false`

---

### Common Configurations

**Standard (most controls)**:
```yaml
results:
  fail: true
  inProgress: false
  notFound: true
  notRequired: true
  pass: true
  warn: false
```

**Always Required**:
```yaml
results:
  fail: true
  inProgress: false
  notFound: true
  notRequired: false  # Can't be marked not required
  pass: true
  warn: false
```

---

## Relations

Defines data sources and subscriptions.

### Structure

```yaml
relations:
- isPrimary: <boolean>
  collection: <uuid>
  domain: <uuid>
  subscription:
    path: <string>
    integration:
      type: <string>
      path: <string>
    note: <string>
```

### Field Definitions

#### `isPrimary`
**Type**: `boolean`
**Required**: Yes
**Description**: Whether this is the primary relation

**Rules**:
- Always `false` for official controls
- Only custom controls use `true`

---

#### `collection`
**Type**: `string` (UUID)
**Required**: Yes
**Description**: Collection UUID

**Standard Value**: `6253b179-630e-46d7-9aa8-88c446a14aaf`

**Rules**:
- Use the standard collection UUID for all official controls

---

#### `domain`
**Type**: `string` (UUID)
**Required**: Yes
**Description**: Domain UUID

**Standard Value**: `09c27275-3aaa-4530-bb62-07dc02d3b63c`

**Rules**:
- Use the Compliance Controls domain UUID for all official controls

---

#### `subscription.path`
**Type**: `string`
**Required**: Yes
**Description**: Occurrence path

**Examples**:
- `security.sast.snyk`
- `testing.unit.junit`
- `ci.commit.history`

**Rules**:
- Matches where integration publishes occurrence data
- Dot-separated path segments
- Coordinate with integration team

---

#### `subscription.integration.type`
**Type**: `string`
**Required**: Yes
**Description**: Integration type

**Common Values**:
- `plugin` - Most integrations
- `api` - Direct API integrations

---

#### `subscription.integration.path`
**Type**: `string`
**Required**: Yes
**Description**: Plugin/integration identifier

**Examples**:
- `snyk-sast`
- `junit`
- `checkmarx`

**Rules**:
- Matches the integration/plugin name
- Coordinate with integration team

---

#### `subscription.note`
**Type**: `string`
**Required**: Yes
**Description**: Subscription type

**Value**: `occurrence`

**Rules**:
- Always `occurrence` for official controls

---

### Multiple Relations

Controls can subscribe to multiple data sources:

```yaml
relations:
- isPrimary: false
  collection: 6253b179-630e-46d7-9aa8-88c446a14aaf
  domain: 09c27275-3aaa-4530-bb62-07dc02d3b63c
  subscription:
    path: testing.unit.junit
    integration:
      type: plugin
      path: junit
    note: occurrence
- isPrimary: false
  collection: 6253b179-630e-46d7-9aa8-88c446a14aaf
  domain: 09c27275-3aaa-4530-bb62-07dc02d3b63c
  subscription:
    path: testing.ci.unit.junit
    integration:
      type: plugin
      path: junit-ci
    note: occurrence
```

---

## Assets

Defines which asset types the control targets.

### Structure

```yaml
assets:
- type: <string>
  cardinality: <string>
  targetAssetTypeUuid: <uuid>
  series:
  - name: <string>
    code: <number>
```

### Field Definitions

#### `type`
**Type**: `string`
**Required**: Yes
**Description**: Asset category

**Valid Values**:
- `module` - Code modules/packages
- `repository` - Source code repositories
- `artifact` - Build artifacts

---

#### `cardinality`
**Type**: `string`
**Required**: Yes
**Description**: Targeting cardinality

**Value**: `all`

**Rules**:
- Always `all` for official controls

---

#### `targetAssetTypeUuid`
**Type**: `string` (UUID)
**Required**: Yes
**Description**: Asset type UUID

**Standard Values**:
- Module: `840b4288-375c-43e3-93d1-b75bef079270`
- Repository: `681da6ae-edbc-4587-8777-1503602abd4a`
- Artifact: `a1d9bdc6-a29c-4247-8b1e-c8bd5fea1b55`

---

#### `series`
**Type**: `array`
**Required**: Yes
**Description**: Asset series configuration

**Standard Configuration**:
```yaml
series:
- name: commit
  code: 2112
- name: tag
  code: 2113
```

**Rules**:
- Usually include both commit and tag
- Use standard codes: commit=2112, tag=2113

---

### Standard Asset Configuration

Most controls use all three asset types:

```yaml
assets:
- type: module
  cardinality: all
  targetAssetTypeUuid: 840b4288-375c-43e3-93d1-b75bef079270
  series:
  - name: commit
    code: 2112
  - name: tag
    code: 2113
- type: repository
  cardinality: all
  targetAssetTypeUuid: 681da6ae-edbc-4587-8777-1503602abd4a
  series:
  - name: commit
    code: 2112
  - name: tag
    code: 2113
- type: artifact
  cardinality: all
  targetAssetTypeUuid: a1d9bdc6-a29c-4247-8b1e-c8bd5fea1b55
  series:
  - name: commit
    code: 2112
  - name: tag
    code: 2113
```

---

## Complete Example

```yaml
id: 09c27275-3aaa-4530-bb62-07dc02d3b63c
displayKey: SNYK
version: '1'
roles: []
path: snyk.sast.vulnerabilities
name: Snyk SAST
fullName: Snyk Static Application Security Testing (SAST)
description: |
  This control evaluates Snyk SAST scan results against policy-defined
  thresholds for vulnerability severity levels.

documentation:
  - title: Snyk Documentation
    url: https://docs.snyk.io/

measures:
- name: required
  type: metric
  value: bool
  node_id: 11111111-1111-1111-1111-111111111111
  description: null
  lineItemException:
    enabled: false
    type: null
    expiration:
      required: false
  children: []

- name: vulnerabilities
  type: section
  value: null
  node_id: 22222222-2222-2222-2222-222222222222
  description: null
  lineItemException:
    enabled: false
    type: null
    expiration:
      required: false
  children:
  - name: critical
    type: section
    value: null
    node_id: 33333333-3333-3333-3333-333333333333
    description: null
    lineItemException:
      enabled: false
      type: null
      expiration:
        required: false
    children:
    - name: maximum
      type: metric
      value: number
      node_id: 44444444-4444-4444-4444-444444444444
      description: null
      lineItemException:
        enabled: false
        type: null
        expiration:
          required: false
      children: []
    - name: exceptions
      type: metric
      value: array.string
      node_id: 55555555-5555-5555-5555-555555555555
      description: null
      lineItemException:
        enabled: false
        type: null
        expiration:
          required: false
      children: []

results:
  fail: true
  inProgress: false
  notFound: true
  notRequired: true
  pass: true
  warn: false

scope: commit
retries: false

relations:
- isPrimary: false
  collection: 6253b179-630e-46d7-9aa8-88c446a14aaf
  domain: 09c27275-3aaa-4530-bb62-07dc02d3b63c
  subscription:
    path: security.sast.snyk
    integration:
      type: plugin
      path: snyk-sast
    note: occurrence

assets:
- type: module
  cardinality: all
  targetAssetTypeUuid: 840b4288-375c-43e3-93d1-b75bef079270
  series:
  - name: commit
    code: 2112
  - name: tag
    code: 2113
- type: repository
  cardinality: all
  targetAssetTypeUuid: 681da6ae-edbc-4587-8777-1503602abd4a
  series:
  - name: commit
    code: 2112
  - name: tag
    code: 2113
- type: artifact
  cardinality: all
  targetAssetTypeUuid: a1d9bdc6-a29c-4247-8b1e-c8bd5fea1b55
  series:
  - name: commit
    code: 2112
  - name: tag
    code: 2113

isOfficial: true
evidenceSubmissions: false
manualAttestations: false
```

---

## Validation Rules

### UUID Requirements
- All UUIDs must be valid v4 format
- Control `id` must be globally unique
- Each measure `node_id` must be unique within the control
- Asset type UUIDs must match standard values
- Collection and domain UUIDs must match standard values

### Naming Requirements
- `path` must be lowercase with dots only
- `displayKey` must be 3-6 uppercase letters
- Measure `name` fields must be lowercase with underscores

### Structure Requirements
- Metrics must have non-null `value` type
- Sections must have `value: null`
- Sections can have children, metrics cannot (except empty array)
- All measures must have `lineItemException` block
- All asset types must have both commit and tag series

### Content Requirements
- `description` should be detailed and informative
- At least one relation required
- At least one asset type required
- At least one measure required (usually `required`)

---

## Common Patterns

See [Patterns](../../patterns/) for detailed pattern implementations:
- [Severity-Based Evaluation](../../patterns/severity-based-evaluation/)
- [Multi-Level Thresholds](../../patterns/multi-level-thresholds/)
- [Exception Handling](../../patterns/exception-handling/)
- [Association Validation](../../patterns/association-validation/)

---

## Further Reading

- [Complete Templates](../../templates/) - Working examples
- [GETTING_STARTED](../../GETTING_STARTED.md) - First control creation
- [CONCEPTS](../../CONCEPTS.md) - Understanding control architecture
- [Measures Deep Dive](../measures/) - Policy configuration system

---

**Need more examples?** → [Templates](../../templates/)

**Building a control?** → [GETTING_STARTED](../../GETTING_STARTED.md)

**Have questions?** → [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

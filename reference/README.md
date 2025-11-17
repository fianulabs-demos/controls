# Reference Documentation

Comprehensive technical reference for all Fianu Official Control components, schemas, and APIs.

## Documentation Sections

### 📋 [Schemas](schemas/)
Complete field-by-field reference for all file formats

- **[spec.yaml](schemas/spec.yaml.md)** - Control specification reference
- **[contents.json](schemas/contents.json.md)** - Component references
- **[Policy Data](schemas/policy-data.md)** - Policy configuration format
- **[Occurrence Data](schemas/occurrence-data.md)** - Occurrence structure
- **[Mapper I/O](schemas/mapper-input-output.md)** - Mapper signatures and data
- **[Rule I/O](schemas/rule-input-output.md)** - Rego input/output reference

**Use when**: You need to know exactly what a field means, its type, constraints, or valid values

### 🏗️ [Architecture](architecture/)
System design, data flows, and component interactions

- **[Overview](architecture/README.md)** - High-level architecture
- **[Data Flow](architecture/data-flow.md)** - How data moves through the system
- **[Evaluation Lifecycle](architecture/evaluation-lifecycle.md)** - Control execution sequence
- **[Diagrams](architecture/diagrams/)** - Visual representations

**Use when**: You want to understand how the system works end-to-end

### 🔧 [Components](components/)
Deep dives into each control component

- **[Mappers](components/mappers/)** - Python mapper development
  - [detail.py Reference](components/mappers/detail-py.md)
  - [display.py Reference](components/mappers/display-py.md)
  - [Python Standard Library](components/mappers/python-stdlib.md)

- **[Rules](components/rules/)** - Rego rule development
  - [rule.rego Reference](components/rules/rule-rego.md)
  - [OPA Builtins](components/rules/opa-builtins.md)
  - [Fianu Builtins](components/rules/fianu-builtins.md)

- **[Testing](components/testing/)** - Test data and validation
  - [Policy Cases](components/testing/policy-cases.md)
  - [Occurrence Payloads](components/testing/occurrence-payloads.md)

**Use when**: You need detailed documentation on how to build a specific component

### 📊 [Measures](measures/)
Policy configuration system reference

- **[Overview](measures/README.md)** - How measures work
- **[Types](measures/types.md)** - Metric vs Section
- **[Value Types](measures/value-types.md)** - bool, number, string, array.string
- **[Hierarchy](measures/hierarchy.md)** - Building measure trees
- **[Common Patterns](measures/common-patterns.md)** - Standard structures

**Use when**: Designing the policy configuration interface for your control

### 🔗 [Relations](relations/)
Data source subscriptions and occurrence handling

- **[Overview](relations/README.md)** - How relations work
- **[Occurrences](relations/occurrences.md)** - Occurrence subscriptions
- **[Integrations](relations/integrations.md)** - Integration types
- **[Multiple Sources](relations/multiple-sources.md)** - Multi-relation patterns

**Use when**: Connecting your control to data sources

### 🎯 [Assets](assets/)
Asset targeting and series configuration

- **[Overview](assets/README.md)** - Asset system overview
- **[Types](assets/types.md)** - Module, Repository, Artifact
- **[Series](assets/series.md)** - Commit vs Tag
- **[UUIDs](assets/uuids.md)** - Standard asset type UUIDs

**Use when**: Configuring which assets your control applies to

### ✅ [Results](results/)
Control evaluation outcomes

- **[Overview](results/README.md)** - Result system overview
- **[States](results/states.md)** - pass, fail, notFound, etc.
- **[Violations](results/violations.md)** - Recording violations

**Use when**: Understanding or configuring control result states

---

## Quick Reference Cards

### Common UUIDs

```yaml
# Asset Type UUIDs
Module:     840b4288-375c-43e3-93d1-b75bef079270
Repository: 681da6ae-edbc-4587-8777-1503602abd4a
Artifact:   a1d9bdc6-a29c-4247-8b1e-c8bd5fea1b55

# Series Codes
Commit: 2112
Tag:    2113

# Domain UUID (most controls use this)
Compliance Controls: 09c27275-3aaa-4530-bb62-07dc02d3b63c
```

### Mapper Signatures

```python
# detail.py
def main(occurrence, context):
    """Transform raw occurrence data"""
    return dict

# display.py
def main(occurrence, attestation, context):
    """Format data for UI display"""
    return dict
```

### Rule Structure

```rego
package rule

default pass = false
default fail = false
default notFound = false
default notRequired = false

import future.keywords

pass if {
    # evaluation logic
}

notRequired if {
    not pass
    data.required == false
}
```

### File Structure

```
control/
├── spec.yaml              # Metadata and measures
├── contents.json          # Component references
├── mappers/
│   ├── detail.py         # Data transformation
│   └── display.py        # UI formatting
├── rule/
│   └── rule.rego         # Policy evaluation
├── inputs/
│   └── data/
│       └── policy_*.json # Test policies
└── testing/
    └── payloads/
        └── occ_*.json    # Test occurrences
```

---

## How to Use This Reference

### By Use Case

| I want to... | Go to... |
|--------------|----------|
| Understand a spec.yaml field | [spec.yaml Reference](schemas/spec.yaml.md) |
| Know what data my mapper receives | [Mapper I/O](schemas/mapper-input-output.md) |
| See available Rego functions | [OPA Builtins](components/rules/opa-builtins.md) |
| Design policy configuration | [Measures Overview](measures/) |
| Subscribe to occurrence data | [Relations Overview](relations/) |
| Target specific asset types | [Assets Overview](assets/) |
| Record violations correctly | [Violations](results/violations.md) |
| Understand system architecture | [Architecture](architecture/) |

### By Component

| Component | Reference | Deep Dive |
|-----------|-----------|-----------|
| spec.yaml | [Schema](schemas/spec.yaml.md) | [Measures](measures/) |
| contents.json | [Schema](schemas/contents.json.md) | N/A |
| detail.py | [I/O Schema](schemas/mapper-input-output.md) | [Mappers Guide](components/mappers/detail-py.md) |
| display.py | [I/O Schema](schemas/mapper-input-output.md) | [Mappers Guide](components/mappers/display-py.md) |
| rule.rego | [I/O Schema](schemas/rule-input-output.md) | [Rules Guide](components/rules/rule-rego.md) |

### By Learning Style

**Reference Reader** (I want specs and tables):
- Start with [Schemas](schemas/)
- Check [Quick Reference](#quick-reference-cards) above

**Visual Learner** (I want diagrams):
- Start with [Architecture](architecture/)
- See [Diagrams](architecture/diagrams/)

**Code-First** (I want examples):
- Start with [Templates](../templates/)
- Refer back to reference as needed

**Concept-First** (I want understanding):
- Start with [Core Concepts](../CONCEPTS.md)
- Deep dive into [Components](components/)

---

## Reference vs Tutorial vs Example

| | Reference | Tutorial | Example |
|---|---|---|---|
| **Purpose** | Specification | Learning | Demonstration |
| **Format** | Tables, schemas | Step-by-step | Complete code |
| **Detail** | Exhaustive | Progressive | Realistic |
| **Use When** | Need exact spec | Learning | Need template |

**Use all three**:
1. Learn from [Tutorials](../tutorials/)
2. Build from [Examples](../examples/)
3. Reference this documentation when stuck

---

## Searchability Tips

All reference docs include:
- 📑 **Table of contents** at the top
- 🔍 **Search keywords** in headings
- 💡 **Examples** for each concept
- ⚠️ **Common mistakes** highlighted
- 🔗 **Cross-references** to related docs

**Pro tip**: Use your browser's find feature (Ctrl/Cmd+F) to search within pages

---

## Status Legend

- ✅ **Complete** - Documentation is comprehensive and reviewed
- 🚧 **In Progress** - Basic documentation exists, being expanded
- 📝 **Planned** - On the roadmap, not yet started

---

## Contributing

Found an error? Missing information? Unclear explanation?

See our [Contributing Guide](../contributing/) for how to improve this documentation.

**We especially need**:
- Real-world examples
- Common pitfall warnings
- Troubleshooting tips
- Diagrams and visualizations

---

## Further Reading

- **[Getting Started](../GETTING_STARTED.md)** - Hands-on tutorial
- **[Core Concepts](../CONCEPTS.md)** - Fundamental understanding
- **[Best Practices](../best-practices/)** - Design guidelines
- **[Examples](../examples/)** - Working controls

---

**Need a specific answer?** → Browse sections above

**Want step-by-step?** → Try [Tutorials](../tutorials/)

**Need working code?** → Check [Examples](../examples/)

**Have a question?** → See [FAQ](../faq/)

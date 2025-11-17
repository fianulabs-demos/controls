# Quickstart: Simple Boolean Check

**Time to complete**: 5 minutes

This is the **absolute simplest** Fianu control possible - it checks if a boolean value is `true`. Perfect for understanding the basic structure before diving into complex examples.

## What You'll Learn

- ✅ The 5 essential files every control needs
- ✅ How data flows through the system
- ✅ What each component does (spec, mappers, rule)
- ✅ How to test a control locally

## The Control

**[simple.boolean.check/](simple.boolean.check/)** - A minimal control that checks a boolean value

**What it does**:
1. Receives data with a boolean field
2. Extracts the boolean value
3. Checks if it's `true`
4. Returns PASS or FAIL

## Quick Start

```bash
# Navigate to the example
cd quickstart/simple.boolean.check

# Look at the structure
ls -R

# Test the mapper locally
python3 << 'EOF'
import sys, json
sys.path.insert(0, 'mappers')
import detail
occ = json.load(open('testing/payloads/occ_case_1.json'))
print(json.dumps(detail.main(occ, {}), indent=2))
EOF

# Package the control
fianu package --path . -o simple-boolean.tgz

# Deploy it
fianu apply --path simple-boolean.tgz
```

## File Structure

```
simple.boolean.check/
├── spec.yaml                 # Control metadata and policy structure
├── contents.json             # Component references
├── mappers/
│   ├── detail.py            # Extracts the boolean value
│   └── display.py           # Formats display
├── rule/
│   └── rule.rego            # Checks if value == true
├── inputs/
│   └── data/
│       └── policy_case_1.json    # Test policy config
└── testing/
    └── payloads/
        └── occ_case_1.json       # Test occurrence data
```

## Deep Dive

For a complete line-by-line explanation of every file and how they work together:

**[📖 Read the Walkthrough](WALKTHROUGH.md)**

The walkthrough covers:
- What each file does and why
- How data flows through the system
- Line-by-line code explanation
- How to test and modify the control
- Key concepts and takeaways

## What's Next?

After completing this quickstart:

### Option 1: Build Your Own
Follow the **[Getting Started Guide](../GETTING_STARTED.md)** to create a custom control from scratch

### Option 2: Learn More
Work through **[Tutorial 1: Hello World](../tutorials/01-hello-world/)** for a deeper explanation

### Option 3: Use Templates
Browse **[Templates](../templates/)** for pre-built scaffolding you can customize

### Option 4: See Real Examples
Check out **[Examples](../examples/)** for production-quality controls

---

## Why This Example?

This is intentionally **the simplest possible control** because:

1. ✅ **Minimal complexity** - No advanced features to distract from core concepts
2. ✅ **Complete** - Has all required files, nothing missing
3. ✅ **Works** - You can actually package and deploy it
4. ✅ **Educational** - Comments and walkthrough explain everything
5. ✅ **Foundation** - Once you understand this, more complex controls make sense

## Key Concepts Demonstrated

| Concept            | File            | What You Learn                     |
|--------------------|-----------------|------------------------------------|
| **Metadata**       | `spec.yaml`     | Control identity and configuration |
| **Organization**   | `contents.json` | How components link together       |
| **Data Transform** | `detail.py`     | Extract and structure data         |
| **Policy Logic**   | `rule.rego`     | Evaluate against rules             |
| **UI Display**     | `display.py`    | Format for dashboard               |
| **Testing**        | `testing/`      | Sample data for validation         |

---

## Common Questions

**Q: Can I use this in production?**
A: This example is for learning. For production, use more robust error handling and validation.

**Q: Why Python for mappers?**
A: Python is widely known and great for data transformation. The mapper interface is simple: `main(input) → output`.

**Q: Why Rego for rules?**
A: Rego (from Open Policy Agent) is designed for policy evaluation. It's declarative and powerful for expressing compliance logic.

**Q: Do I need to know Rego?**
A: You can learn as you go! Start with simple examples like this and gradually build complexity.

**Q: Where does the occurrence data come from?**
A: In production, integrations (Snyk, JUnit, Jira, etc.) produce occurrences. Here we use test data.

---

**Ready?** → [Start the Walkthrough](WALKTHROUGH.md)

**Need help?** → [Troubleshooting Guide](../TROUBLESHOOTING.md)

**Want more?** → [Tutorials](../tutorials/)

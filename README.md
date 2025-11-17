# Fianu Official Controls - Examples & Documentation

Welcome to the Fianu Official Controls examples repository! This comprehensive guide will teach you everything you need to know about creating, testing, and deploying custom compliance controls for your software development lifecycle.

## 🚀 Quick Links

- **[Getting Started](GETTING_STARTED.md)** - Create your first control in 30 minutes
- **[Core Concepts](CONCEPTS.md)** - Understand the architecture and terminology
- **[Troubleshooting](TROUBLESHOOTING.md)** - Solutions to common issues

## 📚 What You'll Find Here

### 🏃 [Quickstart](quickstart/)
The absolute fastest way to get started. A 5-minute walkthrough of the simplest possible control.

**Start here if:** You want to see a working control immediately.

### 📖 [Tutorials](tutorials/)
Six progressive tutorials that take you from "Hello World" to production-ready controls.

1. **Hello World** - Your first control
2. **Vulnerability Scanner** - SAST-style severity checking
3. **Test Results** - JUnit-style test validation
4. **Association Validation** - Jira/PR association checks
5. **Advanced Mappers** - Complex data transformation
6. **Production Ready** - Full-featured control with all bells and whistles

**Start here if:** You prefer structured, step-by-step learning.

### 📋 [Templates](templates/)
Copy-paste scaffolding for common control types. Just customize and deploy!

- **Vulnerability Scanner** - For SAST, DAST, container scanning
- **Test Results** - For unit, functional, integration tests
- **Association Validator** - For Jira, GitHub, GitLab associations
- **Threshold Checker** - For coverage, metrics, quality gates
- **Boolean Check** - For simple pass/fail validations
- **Custom** - Blank template with comprehensive comments

**Start here if:** You know what you need and want to move fast.

### 🎯 [Patterns](patterns/)
Reusable code patterns for common scenarios:

- Severity-based evaluation (critical/high/medium/low)
- Exception handling (CWE, identifiers, locations)
- Location exclusions (file paths, directories)
- Multi-level thresholds (min/max by severity)
- Association validation (issue tracking integration)
- SARIF parsing (SAST tool output)
- JUnit parsing (test framework output)
- Summary aggregation (rollups and counts)

**Start here if:** You need a specific pattern or technique.

### 👨‍🍳 [Recipes](recipes/)
Cookbook-style solutions for specific integrations:

- **Vulnerability Scanning**: Snyk, Checkmarx, Wiz, GitLab, Generic SARIF
- **Test Results**: JUnit, Pytest, Custom formats
- **Code Review**: Jira, GitHub, GitLab
- **Coverage**: Cobertura, JaCoCo, Custom
- **Compliance**: SBOM, Licenses, Signatures
- **Custom**: API integrations, Multi-source, Complex logic

**Start here if:** You're integrating with a specific tool.

### 📖 [Reference Documentation](reference/)
Comprehensive documentation for every component:

- **[Schemas](reference/schemas/)** - Complete field reference for all files
- **[Components](reference/components/)** - Deep dives into mappers, rules, testing
- **[Measures](reference/measures/)** - Policy configuration system
- **[Relations](reference/relations/)** - Data source subscriptions
- **[Assets](reference/assets/)** - Asset types and targeting
- **[Architecture](reference/architecture/)** - System diagrams and data flows

**Start here if:** You need detailed technical specifications.

### 🚢 [Deployment](deployment/)
Guides for deploying controls to production:

- **Local Development** - Testing on your machine
- **GitHub Actions** - Complete workflow examples
- **GitLab CI** - Pipeline configuration
- **Jenkins** - Jenkinsfile examples
- **Packaging & Applying** - Using the Fianu CLI

**Start here if:** You're setting up CI/CD for controls.

### 🛠️ [Tools](tools/)
Developer utilities to accelerate development:

- **scaffold.py** - Interactive control generator
- **validate.py** - Validate control structure
- **test-runner.py** - Local testing utility

**Start here if:** You want automation and validation.

### ✨ [Best Practices](best-practices/)
Guidelines for writing production-quality controls:

- Control Design Principles
- Mapper Development Patterns
- Rule Writing Guidelines
- Testing Strategies
- Error Handling
- Performance Optimization
- Security Considerations
- Naming Conventions

**Start here if:** You want to write high-quality, maintainable controls.

### 💡 [Examples](examples/)
Real-world controls organized by complexity:

- **Simple**: Commit signature, Build required
- **Intermediate**: JUnit tests, Code coverage, Jira association
- **Advanced**: Snyk vulnerabilities, SonarQube quality, Multi-source aggregation

**Start here if:** You learn best from complete, working examples.

### ❓ [FAQ](faq/)
Answers to frequently asked questions about:

- General concepts
- Development workflows
- Deployment processes
- Common troubleshooting

**Start here if:** You have a specific question.

---

## 🎓 Recommended Learning Paths

### Path 1: "I'm brand new to Fianu controls"
1. Read [Core Concepts](CONCEPTS.md) (10 min)
2. Follow [Getting Started](GETTING_STARTED.md) (30 min)
3. Try the [Quickstart](quickstart/) (5 min)
4. Work through [Tutorial 1: Hello World](tutorials/01-hello-world/) (20 min)

### Path 2: "I need to build a specific control type"
1. Browse [Templates](templates/) to find matching type
2. Read the template's README
3. Copy template and customize
4. Reference [Patterns](patterns/) for specific techniques
5. Check [Recipes](recipes/) for your integration

### Path 3: "I want to master control development"
1. Complete all [Tutorials](tutorials/) (2-3 hours)
2. Study [Best Practices](best-practices/)
3. Review [Advanced Examples](examples/advanced/)
4. Deep dive into [Reference Documentation](reference/)

### Path 4: "I need to deploy controls"
1. Read [Deployment Overview](deployment/)
2. Set up [Local Development](deployment/local-development.md)
3. Configure [CI/CD Integration](deployment/cicd/)
4. Follow [Versioning Guide](deployment/versioning.md)

---

## 🏗️ What is a Fianu Official Control?

A **Fianu Official Control** is a policy-driven compliance check that evaluates your software development lifecycle. Controls:

- **Receive** occurrence data from integrations (Snyk, JUnit, Jira, etc.)
- **Transform** data using Python mappers
- **Evaluate** compliance using OPA/Rego policy rules
- **Report** violations and results back to Fianu

### Control Structure

Every control consists of:

```
my-control/
├── spec.yaml              # Control metadata and configuration
├── contents.json          # Component references
├── mappers/
│   ├── detail.py         # Data transformation
│   └── display.py        # UI formatting
├── rule/
│   └── rule.rego         # Policy evaluation
├── inputs/
│   └── data/
│       └── policy_*.json # Test policy configurations
└── testing/
    └── payloads/
        └── occ_*.json    # Test occurrence data
```

### Data Flow

```
┌─────────────────┐
│   Integration   │  (Snyk, JUnit, Jira, etc.)
│   (Occurrence)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   detail.py     │  Transform raw data
│   (Mapper)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   rule.rego     │  Evaluate against policy
│   (Rule)        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   display.py    │  Format for UI
│   (Mapper)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Result      │  (Pass, Fail, NotFound, etc.)
└─────────────────┘
```

---

## 🔧 Prerequisites

Before you begin, ensure you have:

1. **Fianu CLI** installed and configured
   ```bash
   # Installation instructions at: https://docs.fianu.io/cli
   fianu --version
   ```

2. **Fianu Account** with appropriate permissions
   - Client ID and Secret for authentication
   - Access to target environment (dev/qa/prod)

3. **Development Tools**
   - Python 3.8+ (for mappers)
   - Basic understanding of YAML and JSON
   - Familiarity with regular expressions (helpful)
   - OPA/Rego knowledge (can be learned as you go)

4. **Optional but Recommended**
   - Git for version control
   - IDE with YAML/Python/Rego support
   - curl or Postman for API testing

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](contributing/) for:

- How to submit examples
- Documentation style guide
- Code of conduct
- Example templates

---

## 📝 License

This examples repository is provided under [MIT License](../LICENSE).

---

## 🆘 Need Help?

- **Documentation Issues**: [Check Troubleshooting](TROUBLESHOOTING.md)
- **Questions**: [Browse FAQ](faq/)
- **Bug Reports**: [GitHub Issues](https://github.com/fianulabs/official-controls/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/fianulabs/official-controls/discussions)

---

## 🗺️ Repository Map

```
examples/
├── 📘 README.md (you are here)
├── 🚀 GETTING_STARTED.md
├── 🧠 CONCEPTS.md
├── 🔧 TROUBLESHOOTING.md
├── 🏃 quickstart/
├── 📖 tutorials/
├── 📋 templates/
├── 🎯 patterns/
├── 👨‍🍳 recipes/
├── 📚 reference/
├── 🚢 deployment/
├── 🛠️ tools/
├── ✨ best-practices/
├── 💡 examples/
├── ❓ faq/
└── 🤝 contributing/
```

---

**Ready to get started?** → [Begin with Getting Started](GETTING_STARTED.md)

**Just want to try something?** → [Jump to Quickstart](quickstart/)

**Need a specific solution?** → [Browse Recipes](recipes/)

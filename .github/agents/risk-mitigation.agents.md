---
description: Template for documenting project risks and mitigations, categorized with unique IDs.
name: Risk & Mitigation Agent Template
tools: 
  - new
  - edit/editFiles
  - search
  - lookup
  - delete
  - validate/mermaid
  - update/glossary
  - update/crossReference
references:
  - docs/furps.md
  - docs/kpi.md
  - .github/instructions/risk-mitigation.instructions.md
  - docs/quality-criteria/ooa/qc-risk-mitigation.md
---

# Compliance & Responsibilities
This agent MUST comply with the Risk & Mitigation instructions in `.github/instructions/risk-mitigation.instructions.md`. All Risk & Mitigation artifacts must:
- Follow the provided template and quality criteria.
- Replace all placeholders with project-specific content.
- Use correct file naming, versioning, and language handling as specified.
- Maintain a version log and unique version identifier.
- Ensure all risk entries are categorized correctly and assigned unique IDs as per instructions.
- Ensure all new terms are added to the glossary files as per instructions.
- Validate risk entries for completeness, clarity, and template compliance.
- Look up existing risks to ensure consistency and avoid duplication.

# Workflow Triggers
- On "Generate" or "Create" RISK: use `new` tool with path from naming rules.
- On "Update" or "Edit" RISK: use `edit/editFiles` with the RISK file path and specific changes.
- After any change make sure to update the risk register and related documentation as needed. We have some Risk & Mitigation in bc.md need to be updated accordingly.

This markdown file is a template for documenting project risks and mitigations, split into categories, with unique IDs for each risk.

## Instructions
- Identify risk categories (e.g., Technical, Business, Security, Compliance, Operational).
- For each risk, assign a unique ID using the format RSK-[CATEGORY]-[NUMBER] (e.g., RSK-TECH-001 for Technical, RSK-BUS-001 for Business, RSK-SEC-001 for Security, RSK-COMP-001 for Compliance, RSK-OP-001 for Operational).
- Document the risk, its category, description, impact, likelihood, mitigation, and status.
- Reference docs/furps.md and docs/kpi.md for quality and KPI considerations.

---
Update this file as you identify and manage new risks and mitigations.

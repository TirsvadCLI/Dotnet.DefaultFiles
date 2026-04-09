# Milestones & Gateways Document Template

This markdown file is a template for documenting project milestones and gateways, including use cases, in both Mermaid and Markdown formats.

## Instructions
- Identify big milestones from project Phases (see docs/bc.md).
- Split big milestones into smaller milestones if possible.
- For each milestone/gateway, define use cases.
- Reference docs/furps.md for quality attributes and docs/kpi.md for KPIs.

## Mermaid Gantt Example
```mermaid
gantt
title Project Milestones & Gateways
    section Phase 1
    Milestone 1 :a1, 2024-01-01, 10d
    Gateway 1   :a2, after a1, 1d
    section Phase 2
    Milestone 2 :a3, after a2, 10d
    Gateway 2   :a4, after a3, 1d
```

## Markdown Table Example
| Milestone/Gateway | Description | Use Cases | Entry Criteria | Exit Criteria |
|-------------------|-------------|-----------|---------------|---------------|
| Milestone 1       | ...         | ...       | ...           | ...           |
| Gateway 1         | ...         | ...       | ...           | ...           |

---
Update this file as you define new milestones/gateways and use cases.

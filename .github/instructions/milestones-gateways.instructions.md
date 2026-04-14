---
description: Instructions for documenting project milestones and gateways.
name: Milestones & Gateways Documentation Instructions
applyTo: 'docs/milestones-gateways.md'
references:
  - docs/furps.md
  - docs/kpi.md
  - docs/bc.md
  - docs/quality-criteria/milestones-gateways/qc-milestones-gateways.md
---

# Milestones & Gateways Documentation Instructions

This file provides templates and instructions for documenting project milestones and gateways using Mermaid diagrams and Markdown. Milestones/gateways should be grouped by iteration rather than timeline.

## How to Use
1. Analyze bc.md to identify key milestones and gateways based on the business capabilities and use cases defined.
1. If a big milestone can be split, define smaller milestones.
1. For each milestone/gateway, define:
   - Name
   - Description
   - Entry/Exit Criteria
   - Associated Use Cases
   - Quality Criteria (see qc-milestones-gateways.md)
   - KPIs (see docs/kpi.md)
1. Analyze furps.md to identify use cases that can be associated with each milestone/gateway. Each use case should reference the relevant milestone/gateway in its documentation (e.g., in docs/use-cases.md).
1. Each use case should be small. Example if CRUD, each operation (Create, Read, Update, Delete) should be a separate use case. Each use case should reference the relevant milestone/gateway in its documentation (e.g., in docs/use-cases.md).
1. Visualize the milestones/gateways using Mermaid Gantt or flow diagrams.
1. Add a table summarizing the milestones/gateways and their associated use cases.

## Templates
```markdown
# Gateway for [insert preject name]

## Metadata
| Key               | Value                             |
|-------------------|-----------------------------------|
| Id                | MILESTONE                         |
| crossReference    | BC<br>FURPS<br>KPI                |

## Version Log
| Version | Date       | Description              | Author     |
|---------|------------|--------------------------|------------|
| 0001    | [Insert Today Date yyyy-mm-dd] | Initial                  | <Insert Author Name> | 

## Gantt diagram
```

```mermaid
gantt
title Project Milestones and Gateways
    section Phase 1
    Gateway 1 :a1, [Insert Start Date], 10d
    Gateway 2   :a2, after a1, 1d
    section Phase 2
    Gateway 3 :a3, after a2, 10d
    Gateway 4   :a4, after a3, 1d
```

```markdown
## Gateways & Milestones 
| Milestone/Gateway | Description | Entry Criteria | Exit Criteria |
|-------------------|-------------|---------------|---------------|
| Gateway 1         | ...         | ...           | ...           |
| Gateway 2         | ...         | ...           | ...           |

## Use cases associated with each milestone/gateway
| Use Case ID | Description | Milestone/Gateway | CrossReference |
|-------------|-------------|-------------------|----------------|
| uc-001      | ...         | Gateway 1         | REQ-xx-xxx     |
| uc-002      | ...         | Gateway 1         | REQ-xx-xxx     |
| uc-003      | ...         | Gateway 2         | REQ-xx-xxx     |
| uc-004      | ...         | Gateway 2         | REQ-xx-xxx     |
```

---
Update this file as you define new milestones/gateways.

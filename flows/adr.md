# Architecture Decision Records (ADR) Flow

## Overview

ADR (Architecture Decision Records) is a structured approach to documenting significant architectural and technical decisions. Each ADR captures the context, considered options, decision rationale, and consequences - creating a traceable history of why the system evolved the way it did.

This flow integrates with the broader development workflow (SDD/DDD/TDD/VDD) and provides:

- **Decision Traceability**: Every architectural choice is documented with rationale
- **Context Preservation**: Future developers understand why decisions were made
- **Review Process**: Staged approval ensures decisions are validated
- **Cross-References**: Decisions link to related ADRs, requirements, and implementations

## Flow Phases

```
DRAFT → REVIEW → APPROVED | REJECTED
  ↑        ↑         ↓
  └────────┴─────────┘ (iterate until decision)
```

### Phase 1: DRAFT

**Input**: Architectural question or decision needed
**Output**: `flows/adr-[number]-[name]/adr.md`

Draft captures the initial decision proposal:
- Problem context and drivers
- Considered options with pros/cons
- Proposed decision
- Expected consequences

### Phase 2: REVIEW

**Input**: Completed draft
**Output**: Updated ADR with review feedback

Review validates the decision:
- Technical accuracy verification
- Impact assessment
- Alternative consideration
- Stakeholder feedback collection

### Phase 3: DECISION

**Status**: APPROVED | REJECTED | SUPERSEDED

Final decision state:
- **APPROVED**: Decision is accepted and should be followed
- **REJECTED**: Decision was not accepted (document why)
- **SUPERSEDED**: Replaced by newer ADR (link to replacement)

---

## Directory Structure

```
flows/
├── adr.md                          # This file (flow reference)
├── .templates/adr/                 # Templates for new ADRs
│   ├── adr.md                      # Main ADR template
│   ├── _status.md                  # Status tracking template
│   └── lightweight.md              # Lightweight ADR for small decisions
├── adr-index.md                    # Master index of all ADRs
└── adr-[NNN]-[decision-name]/      # Per-ADR directory
    ├── adr.md                      # Main decision record
    ├── _status.md                  # Current phase + review status
    └── [attachments]/              # Supporting diagrams, research, etc.
```

---

## Starting a New ADR

### New Decision
```
/adr start [name]
```

Creates `flows/adr-[NNN]-[name]/` with templates and opens DRAFT phase.
Auto-assigns next available ADR number.

### Resume Existing
```
/adr resume [number-or-name]
```

Reads `_status.md` to determine current phase and continues from there.

### Quick/Lightweight
```
/adr quick [name]
```

Creates a lightweight ADR for smaller decisions using simplified template.

### List All
```
/adr list
```

Shows all ADRs with their status (draft/review/approved/rejected/superseded).

### Status
```
/adr status
```

Shows ADRs currently in DRAFT or REVIEW phase.

---

## Phase Transitions

### DRAFT → REVIEW
- [ ] All sections completed
- [ ] At least 2 options considered
- [ ] Consequences documented
- [ ] User explicitly approves: "ready for review"

### REVIEW → APPROVED
- [ ] Technical review completed
- [ ] Stakeholder feedback addressed
- [ ] No blocking concerns
- [ ] Reviewer explicitly approves: "ADR approved"

### REVIEW → REJECTED
- [ ] Decision rejected with documented rationale
- [ ] Alternative direction noted (if applicable)
- [ ] Reviewer explicitly states: "ADR rejected"

---

## Status Tracking

Each ADR directory has `_status.md`:

```markdown
# Status: ADR-[NNN] [name]

## Current Phase
DRAFT | REVIEW | APPROVED | REJECTED | SUPERSEDED

## Phase Status
DRAFTING | AWAITING_REVIEW | IN_REVIEW | DECIDED

## Last Updated
[DATE] by [AGENT/PERSON]

## Reviewers
- [ ] [Reviewer 1]: [pending/approved/concerns]
- [ ] [Reviewer 2]: [pending/approved/concerns]

## Review Comments
- [Date]: [Comment from reviewer]

## Progress
- [ ] Draft created
- [ ] Options documented
- [ ] Consequences analyzed
- [ ] Ready for review
- [ ] Review completed
- [ ] Decision made

## Supersedes
[If this ADR replaces another: ADR-XXX]

## Superseded By
[If this ADR was replaced: ADR-YYY]

## Related ADRs
- ADR-XXX: [relationship description]
- ADR-YYY: [relationship description]

## Implementation References
- [Link to implementing PRs, issues, or specs]
```

---

## ADR Index (adr-index.md)

The index provides lookup and cross-referencing in markdown table format:

```markdown
| # | Name | Title | Status | Created | Decided | File |
|---|------|-------|--------|---------|---------|------|
| 1 | use-tower-middleware | Use Tower for Middleware | approved | 2025-01-15 | 2025-01-20 | adr-001-use-tower-middleware/adr.md |
| 2 | redis-client-design | Redis Client Design | approved | 2025-01-18 | 2025-01-25 | adr-002-redis-client-design/adr.md |
```

Categories and relationships are tracked in separate sections of the index file.

---

## Integration with Development Flows

### ADRs and SDD/DDD/TDD/VDD

ADRs complement the development flows:

1. **During Requirements**: Reference relevant ADRs that constrain design
2. **During Specifications**: Create new ADRs for significant decisions
3. **During Implementation**: Link to ADRs that guided implementation
4. **Post-Implementation**: Update ADRs with lessons learned

### Cross-Referencing

In spec documents:
```markdown
## Architecture Decisions
This feature implements decisions from:
- ADR-001: Tower middleware architecture
- ADR-002: Redis client design
```

In ADRs:
```markdown
## Implementation References
- `flows/sdd-feature-x/02-specifications.md`
- PR #123: Initial implementation
```

---

## ADR Template Structure

### Standard ADR Template

```markdown
# ADR-[NNN]: [Title]

## Meta
- **Number**: ADR-[NNN]
- **Type**: constraining | enabling (optional)
- **Status**: DRAFT | REVIEW | APPROVED | REJECTED | SUPERSEDED
- **Created**: [date]
- **Decided**: [date, if decided]
- **Author**: [name]
- **Reviewers**: [names]

### ADR Types
- **constraining**: Selects from options, closes alternatives (e.g., "Use PostgreSQL, not MongoDB")
- **enabling**: Adds new capabilities, expands scope (e.g., "Add Loongson support")

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision Drivers

- [driver 1: description]
- [driver 2: description]
- [driver 3: description]

## Considered Options

### Option 1: [name]

**Description**: [what this option entails]

**Pros**:
- [advantage 1]
- [advantage 2]

**Cons**:
- [disadvantage 1]
- [disadvantage 2]

### Option 2: [name]

[same structure]

### Option 3: [name]

[same structure]

## Decision

We will use **[chosen option]** because [rationale].

## Consequences

### Positive
- [positive consequence 1]
- [positive consequence 2]

### Negative
- [negative consequence 1]
- [negative consequence 2]

### Neutral
- [neutral observation]

## Related Decisions
- ADR-XXX: [how it relates]

## References
- [external links, research, discussions]

## Tags
[space-separated tags for categorization]
```

---

## Best Practices

### Do
- Document decisions as close to decision time as possible
- Include rejected options (they provide context)
- Link to related ADRs and specs
- Update status promptly when decisions are made
- Keep language clear and accessible

### Don't
- Skip the "considered options" section
- Leave ADRs in DRAFT indefinitely
- Document implementation details (that's for specs)
- Forget to update related ADRs when decisions change
- Use ADRs for trivial decisions (use inline comments instead)

---

## When to Create an ADR

Create an ADR when:
- Choosing between technologies or frameworks
- Designing system architecture or major components
- Making decisions that affect multiple parts of the system
- Establishing patterns or conventions
- Decisions that are hard to reverse

Skip ADR when:
- Routine implementation choices
- Well-established patterns already documented
- Decisions with obvious single choice
- Temporary or experimental changes

---

## Migration from Legacy ADRs

If you have existing ADRs in `.claude/` or other locations:

1. Create `flows/adr-index.md` with existing ADR metadata
2. Move ADRs to `flows/adr-[NNN]-[name]/` structure
3. Add `_status.md` to each ADR directory
4. Update cross-references in specs and code

---

*Version: 1.0*
*Created: 2025-03-01*

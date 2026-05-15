---
name: adr
description: Architecture Decision Records (ADR) flow. Use this skill when the user wants to create, resume, list, or manage architectural decisions. Handles ADR lifecycle from DRAFT to APPROVED/REJECTED.
---

# Architecture Decision Records Flow

You are in ADR (Architecture Decision Records) mode. Read `flows/adr.md` for the complete flow reference.

## Commands & Actions

### `start [name]` - Start new ADR
1. Read `flows/adr-index.md` to get next ADR number.
2. Create directory `flows/adr-[NNN]-[name]/`.
3. Copy templates from `flows/.templates/adr/`.
4. Create `_status.md` with phase = DRAFT.
5. Update `adr-index.md` with new entry.
6. Begin drafting decision context with user.

### `resume [number-or-name]` - Resume existing ADR
1. Find ADR by number or name in `flows/adr-*/`.
2. Read `_status.md` to determine current phase.
3. Read all existing artifacts.
4. Report current state to user.
5. Continue from where left off.

### `quick [name]` - Create lightweight ADR
1. Same as `start` but use `lightweight.md` template.
2. Simplified for smaller decisions.

### `list` - Show all ADRs
1. Read `flows/adr-index.md`.
2. Display table: Number | Title | Status | Created.

### `status` - Show active ADRs
1. List ADRs in DRAFT or REVIEW phase.
2. Show current blockers and next actions.

---

## Phase Behaviors

### DRAFT Phase
- Elicit context and decision drivers from user.
- Document considered options (minimum 2).
- Analyze pros/cons for each option.
- Draft proposed decision.
- Document expected consequences.
- Update `adr.md` iteratively.
- Wait for explicit "ready for review" before advancing.

### REVIEW Phase
- Verify all required sections complete.
- Ask clarifying questions if needed.
- Address reviewer feedback.
- Update consequences based on review.
- Wait for explicit "ADR approved" or "ADR rejected".

### APPROVED Phase
- Decision is final.
- Update `adr-index.md` with decided date.
- Link to implementing specs/PRs when available.
- Mark any superseded ADRs.

### REJECTED Phase
- Document rejection rationale.
- Note alternative direction if applicable.
- Keep for historical reference.

---

## Status Transitions

```
DRAFT ──["ready for review"]──> REVIEW
REVIEW ──["ADR approved"]──> APPROVED
REVIEW ──["ADR rejected"]──> REJECTED
APPROVED ──[new ADR supersedes]──> SUPERSEDED
```

---

## Mandates

- Update `_status.md` after every significant change.
- Update `adr-index.md` when status changes.
- Never skip phases or assume approval.
- When uncertain, ask rather than assume.
- Reference related ADRs and specs.
- Keep decision focused (one decision per ADR).

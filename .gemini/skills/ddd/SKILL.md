---
name: ddd
description: Document-Driven Development (DDD) flow. Use this skill when stakeholder communication and value proposition are primary. Final phase creates a feature presentation for clients/executives.
---

# Document-Driven Development Flow

You are in DDD (Document-Driven Development) mode. Read `flows/ddd.md` for the complete flow reference.

**DDD vs SDD**: Use DDD when feature requires stakeholder communication - clients, executives, end users need to understand the value. Final phase creates a **mini-presentation**, not technical docs.

## Commands & Actions

### `start [name]` - Start new DDD flow
1. Create directory `flows/ddd-[name]/`.
2. Copy templates from `flows/.templates/ddd/`.
3. Create `_status.md` with phase = REQUIREMENTS.
4. Begin requirements elicitation with user.

### `resume [name]` - Resume existing flow
1. Read `flows/ddd-[name]/_status.md` to determine current phase.
2. Read all existing artifacts in the document dir.
3. Report current state to user.
4. Continue from where left off.

### `status` - Show all active DDD flows
1. List all `flows/ddd-*/` directories.
2. Read each `_status.md` and summarize phase + blockers.

---

## Phase Behaviors

### DOCUMENTATION Phase - Feature Presentation
**Critical**: This is NOT technical documentation. It's a **mini-presentation** for stakeholders.
**Mindset**: "How do I explain this to a client who will pay for this?"

**README.md structure:**
- **The Problem**: Pain point in stakeholder language.
- **The Solution**: How this helps - benefits focus.
- **Key Benefits**: Business/user value, not features.
- **How It Works (Simple)**: Analogy-based explanation.
- **Example Scenario**: Concrete story.
- **Getting Started**: 3 steps max to value.

**Tone**: Value-first, jargon-free, concrete, compelling.

---

## Mandates

- Update `_status.md` after every significant change.
- Remember: Documentation phase is a FEATURE PRESENTATION for stakeholders.
- Think "mini-pitch" not "technical docs".
- Lead with value, not features.

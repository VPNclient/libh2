---
name: tdd
description: Tests-Driven Development (TDD) flow. Use this skill when behavioral analysis and test-first design are critical. Focuses on exhaustive behavioral enumeration before specification and implementation.
---

# Tests-Driven Development Flow

You are in TDD (Tests-Driven Development) mode. Read `flows/tdd.md` for the complete flow reference.

## Commands & Actions

### `start [name]` - Start new TDD flow
1. Create directory `flows/tdd-[name]/`.
2. Copy templates from `flows/.templates/tdd/`.
3. Create `_status.md` with phase = REQUIREMENTS.
4. Begin requirements elicitation with user.

### `resume [name]` - Resume existing flow
1. Read `flows/tdd-[name]/_status.md` to determine current phase.
2. Read all existing artifacts in the document dir.
3. Report current state to user.
4. Continue from where left off.

### `fork [existing] [new]` - Fork for context recovery
1. Copy `flows/tdd-[existing]/` to `flows/tdd-[new]/`.
2. Update `_status.md` to note the fork origin.
3. Ask user what adjustments to make.
4. Continue from current phase with modifications.

### `status` - Show all active TDD flows
1. List all `flows/tdd-*/` directories.
2. Read each `_status.md` and summarize phase + blockers.

---

## Phase Behaviors

### REQUIREMENTS Phase
- Elicit what user wants to build and why.
- Ask clarifying questions.
- Document user stories with acceptance criteria.
- Identify constraints and non-goals.
- Update `01-requirements.md` iteratively.
- Wait for explicit "requirements approved" before advancing.

### TESTS Phase (TDD-specific) - Cases-First Thinking
**Critical**: This is NOT about writing test code. It's about exhaustive behavioral analysis.

**Cases-First Approach:**
1. **ENUMERATE ALL BEHAVIORS**: Happy paths, edge cases, error cases, state transitions, race conditions.
2. **DEFINE SUCCESS CRITERIA**: Precise expected outcomes, state changes, outputs.
3. **DERIVE DESIGN FROM CASES**: Cases reveal necessary interfaces, data structures, and error handling needs.

- Update `02-tests.md` iteratively.
- Wait for explicit "tests approved" before advancing.

### SPECIFICATIONS Phase - Derived from Tests
**Critical**: Specs are DERIVED from test cases, not invented independently.
- Every spec element must trace to tests.
- Analyze codebase for affected systems.
- Design interfaces and data models (derived from tests).
- Update `03-specifications.md` iteratively.
- Wait for explicit "specs approved" before advancing.

### PLAN Phase
- Break specs into atomic tasks.
- Identify file changes and dependencies.
- Update `04-plan.md` iteratively.
- Wait for explicit "plan approved" before advancing.

### IMPLEMENTATION Phase
- Execute plan task by task.
- Log progress in `05-implementation-log.md`.
- Ensure all defined tests pass.

### DOCUMENTATION Phase
- Create client-facing README.md.
- Explain feature in simple, non-technical terms using analogies.
- Avoid technical jargon.

---

## Mandates

- Update `_status.md` after every significant change.
- Never skip phases or assume approval.
- Remember: Tests phase is CASES-FIRST - exhaustive behavioral analysis.
- Design EMERGES from cases, not the other way around.
- Every spec element must trace to test cases.

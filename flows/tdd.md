# Tests-Driven Development (TDD) Flow

## Overview

TDD extends Document-Driven Development by adding a **Tests phase** between Requirements and Specifications. This phase defines test cases in a simple, readable format before any technical specification is written. This ensures tests drive the design and implementation. This enables:

- **Test-First Thinking**: Define success criteria before implementation details
- **Clear Expectations**: Everyone agrees on what "done" looks like
- **Design Influence**: Tests inform architecture, not vice versa
- **Traceability**: Every requirement has corresponding tests
- **Resumability**: Test cases preserved across sessions

## Flow Phases

```
REQUIREMENTS → TESTS → SPECIFICATIONS → PLAN → IMPLEMENTATION → DOCUMENTATION
     ↑          ↑        ↑            ↑           ↑                ↑
     └──────────┴────────┴────────────┴───────────┴────────────────┘ (iterate at any phase)
```

### Phase 1: Requirements

**Input**: User describes the feature/change they want
**Output**: `flows/tdd-[name]/01-requirements.md`

Requirements capture the **what** and **why**:
- Problem being solved
- User stories (As a... I want... So that...)
- Acceptance criteria (Given/When/Then)
- Constraints and non-goals
- Open questions

### Phase 2: Tests (TDD-specific) - Cases-First Thinking

**Input**: Approved requirements
**Output**: `flows/tdd-[name]/02-tests.md`

**Critical**: This phase is NOT about writing test code. It's about **exhaustive behavioral analysis** - identifying ALL cases that define correct behavior. Logic will emerge FROM these cases.

#### Cases-First Approach

```
1. ENUMERATE ALL BEHAVIORS
   - Happy paths (normal operation)
   - Edge cases (boundaries, limits)
   - Error cases (invalid input, failures)
   - Race conditions (concurrent scenarios)
   - State transitions (before/after)

2. DEFINE SUCCESS CRITERIA FOR EACH
   - What exactly should happen?
   - What state changes occur?
   - What outputs are produced?

3. IDENTIFY COVERAGE GAPS
   - Which behaviors are untestable? Why?
   - Which require integration tests?
   - Which require manual verification?

4. DESIGN EMERGES FROM CASES
   - Cases reveal necessary interfaces
   - Cases reveal data structures
   - Cases reveal error handling needs
```

#### Test Case Format

```markdown
## Behavior: [Descriptive behavior name]

**Requirement**: [Linked requirement ID]
**Type**: unit | integration | e2e

### Case 1: [Specific scenario]
**Given**: [Complete initial state]
**When**: [Exact action/event]
**Then**: [Precise expected outcome]

### Case 2: [Edge scenario]
**Given**: [Edge condition state]
**When**: [Action at boundary]
**Then**: [Expected boundary behavior]

### Case 3: [Error scenario]
**Given**: [State that will cause error]
**When**: [Action that triggers error]
**Then**: [Expected error handling]

### Derived Design Implications
- [Interface needed for this behavior]
- [Data structure implied by cases]
- [Error type needed]
```

#### Completeness Checklist

Before approving tests phase:
- [ ] All requirements have corresponding behaviors
- [ ] All happy paths covered
- [ ] All edge cases identified
- [ ] All error scenarios defined
- [ ] State transitions documented
- [ ] Integration points identified
- [ ] Design implications extracted

### Phase 3: Specifications - Derived from Tests

**Input**: Approved test cases
**Output**: `flows/tdd-[name]/03-specifications.md`

**Critical**: Specifications are DERIVED from test cases, not invented independently. Each spec element must trace to test cases that validate it.

#### Derivation Process

```
Test Cases → Implied Interfaces → Specifications
Test Cases → Implied Data Structures → Specifications
Test Cases → Implied Error Handling → Specifications
```

#### Specification Structure

```markdown
## Interface: [Name]

**Derived from tests**: [List of test case IDs]

### Methods/Functions
[Each method exists because tests require it]

### Data Structures
[Each structure exists because tests operate on it]

### Error Types
[Each error exists because tests expect it]

### Traceability Matrix
| Spec Element | Validated By Tests |
|--------------|-------------------|
| method_a()   | test_1, test_2    |
| struct_b     | test_3, test_4    |
```

Specifications add the **how** at architectural level, designed to pass tests:
- Affected systems/components (implied by integration tests)
- Data models and interfaces (implied by test inputs/outputs)
- Behavior descriptions (directly from test cases)
- Edge cases and error handling (from error test cases)
- Dependencies and integration points (from integration tests)
- **Every spec element traceable to tests**

### Phase 4: Plan

**Input**: Approved specifications
**Output**: `flows/tdd-[name]/04-plan.md`

Plan breaks down into actionable implementation:
- Task breakdown with dependencies
- File changes (create/modify/delete)
- Testing strategy (unit/integration/e2e)
- Rollback considerations
- Estimated complexity per task

### Phase 5: Implementation

**Input**: Approved plan
**Output**: Working code + `flows/tdd-[name]/05-implementation-log.md`

Implementation executes the plan:
- Track progress against plan
- Document deviations and why
- Capture learnings for spec refinement
- **Tests must pass** before marking complete

### Phase 6: Documentation

**Input**: Completed implementation
**Output**: `flows/tdd-[name]/README.md`

Client-facing documentation explains the feature in simple terms:
- **What it does**: Feature functionality in plain language
- **How it works**: Simple, non-technical explanation ("on your fingers")
- **Usage examples**: Basic examples showing typical use cases
- **Benefits**: Key advantages for the end user/client

---

## Directory Structure

```
flows/
├── tdd.md                      # This file (flow reference)
├── .templates/
│   ├── requirements.md
│   ├── tests.md                # NEW: Test cases template
│   ├── specifications.md
│   ├── plan.md
│   ├── implementation-log.md
│   └── readme.md
└── tdd-[feature-name]/         # Per-feature document directory
    ├── 01-requirements.md
    ├── 02-tests.md             # NEW: Test cases
    ├── 03-specifications.md
    ├── 04-plan.md
    ├── 05-implementation-log.md
    ├── README.md
    └── _status.md              # Current phase + blockers
```

---

## Starting a New TDD Flow

### New Feature
```
/tdd start [feature-name]
```

Creates `flows/tdd-[feature-name]/` with templates and opens requirements phase.

### Resume Existing
```
/tdd resume [feature-name]
```

Reads `_status.md` to determine current phase and continues from there.

### Fork (Context Recovery)
```
/tdd fork [existing-name] [new-name]
```

When context is lost or pivoting: creates new document dir copying existing artifacts as starting point, with `_status.md` noting the fork.

---

## Phase Transitions

### Requirements → Tests
- [ ] Requirements reviewed by user
- [ ] Open questions resolved
- [ ] Scope clearly bounded
- [ ] User explicitly approves: "requirements approved"

### Tests → Specifications
- [ ] Test cases reviewed by user
- [ ] All requirements have corresponding tests
- [ ] Edge cases covered
- [ ] User explicitly approves: "tests approved"

### Specifications → Plan
- [ ] Specifications reviewed by user
- [ ] All affected systems identified
- [ ] Edge cases documented
- [ ] User explicitly approves: "specs approved"

### Plan → Implementation
- [ ] Plan reviewed by user
- [ ] Tasks are atomic and testable
- [ ] Dependencies mapped
- [ ] User explicitly approves: "plan approved"

### Implementation → Documentation
- [ ] Implementation complete and tested
- [ ] All tests passing
- [ ] Ready for client communication
- [ ] User approves documentation phase: "ready for docs"

---

## Status Tracking

Each document dir has `_status.md`:

```markdown
# Status: tdd-[name]

## Current Phase
TESTS (in progress)

## Last Updated
2024-12-22 by Claude

## Blockers
- None

## Progress
- [x] Requirements drafted
- [x] Requirements approved
- [x] Test cases drafted  ← current
- [ ] Tests approved
- [ ] Specifications drafted
- [ ] Specifications approved
- [ ] Plan drafted
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete
- [ ] Documentation drafted
- [ ] Documentation approved

## Context Notes
Key decisions or context for resuming:
- Tests must cover edge case where input is empty
- User wants integration tests for API endpoints
```

---

## Iteration Protocol

At any phase, user can request changes:

1. **Minor adjustment**: Agent modifies current document in place
2. **Major pivot**: Fork to new document dir with adjusted requirements
3. **Scope change**: Go back to requirements phase

After each iteration:
- Update `_status.md` with what changed and why
- Increment version in document header if major change

---

## Session Handoff

When ending a session mid-flow:

1. Update `_status.md` with current state
2. Document any in-flight reasoning
3. List explicit next steps
4. Note any context that might be lost

New session reads `_status.md` first to reconstruct context.

---

## Integration with CLAUDE.md

TDD follows CLAUDE.md principles:
- **Explicit predictions**: State expected outcomes before implementation
- **Checkpoints**: Verify after each task, not batch
- **One test at a time**: During implementation phase
- **Autonomy boundaries**: Phase transitions require user approval

---

## Anti-Patterns

- **Skipping tests phase**: Defeats the purpose of TDD
- **Vague test cases**: "It should work" → define specific expected outcomes
- **Tests after implementation**: Writing tests after code defeats TDD
- **Unmapped requirements**: Requirements without corresponding tests
- **Premature implementation**: Writing code before tests approved
- **Silent pivots**: Changing scope without updating artifacts
- **Stale status**: Forgetting to update `_status.md`
- **Ignoring failing tests**: Implementation complete but tests failing

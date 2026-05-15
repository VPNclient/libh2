# Tests-Driven Development Flow

You are entering TDD (Tests-Driven Development) mode. Read `flows/tdd.md` for the complete flow reference.

## Command: $ARGUMENTS

Parse the arguments to determine the action:

### `start [name]` - Start new TDD flow
1. Create directory `flows/tdd-[name]/`
2. Copy templates from `flows/.templates/tdd/`
3. Create `_status.md` with phase = REQUIREMENTS
4. Begin requirements elicitation with user

### `resume [name]` - Resume existing flow
1. Read `flows/tdd-[name]/_status.md` to determine current phase
2. Read all existing artifacts in the document dir
3. Report current state to user
4. Continue from where left off

### `fork [existing] [new]` - Fork for context recovery
1. Copy `flows/tdd-[existing]/` to `flows/tdd-[new]/`
2. Update `_status.md` to note the fork origin
3. Ask user what adjustments to make
4. Continue from current phase with modifications

### `status` - Show all active TDD flows
1. List all `flows/tdd-*/` directories
2. Read each `_status.md` and summarize phase + blockers

### No arguments or `help`
1. Show available commands and current active flows

---

## Phase Behaviors

### REQUIREMENTS Phase
- Elicit what user wants to build and why
- Ask clarifying questions
- Document user stories with acceptance criteria
- Identify constraints and non-goals
- Update `01-requirements.md` iteratively
- Wait for explicit "requirements approved" before advancing

### TESTS Phase (TDD-specific) - Cases-First Thinking

**Critical**: This is NOT about writing test code. It's about exhaustive behavioral analysis.

**Cases-First Approach:**
```
1. ENUMERATE ALL BEHAVIORS
   - Happy paths, edge cases, error cases
   - State transitions, race conditions
   - ALL scenarios that define correctness

2. DEFINE SUCCESS CRITERIA FOR EACH
   - Precise expected outcomes
   - State changes
   - Outputs produced

3. DERIVE DESIGN FROM CASES
   - Cases reveal necessary interfaces
   - Cases reveal data structures
   - Cases reveal error handling needs
```

**Per case document:**
- Given: Complete initial state
- When: Exact action/event
- Then: Precise expected outcome
- Design implications: What interface/structure this case requires

**Completeness check before approval:**
- [ ] All requirements have behaviors
- [ ] All edge cases identified
- [ ] All error scenarios defined
- [ ] Design implications extracted

- Update `02-tests.md` iteratively
- Wait for explicit "tests approved" before advancing

### SPECIFICATIONS Phase - Derived from Tests

**Critical**: Specs are DERIVED from test cases, not invented independently.

**Derivation:**
```
Test Cases → Implied Interfaces → Specs
Test Cases → Implied Data Structures → Specs
Test Cases → Implied Error Handling → Specs
```

**Every spec element must trace to tests:**
- Interface exists because tests require it
- Data structure exists because tests operate on it
- Error type exists because tests expect it

- Analyze codebase for affected systems
- Design interfaces and data models (derived from tests)
- Document edge cases (from test cases)
- Include traceability matrix (spec element → tests)
- Update `03-specifications.md` iteratively
- Wait for explicit "specs approved" before advancing

### PLAN Phase
- Break specs into atomic tasks
- Identify file changes and dependencies
- Estimate complexity
- Update `04-plan.md` iteratively
- Wait for explicit "plan approved" before advancing

### IMPLEMENTATION Phase
- Execute plan task by task
- Follow CLAUDE.md testing protocol (one test at a time)
- Log progress in `05-implementation-log.md`
- Document any deviations from plan
- Ensure all defined tests pass
- Wait for implementation completion before advancing

### DOCUMENTATION Phase
- Create client-facing README.md
- Explain feature in simple, non-technical terms
- Provide "how it works" explanation using analogies
- Add practical usage examples
- Focus on benefits and functionality from client perspective
- Avoid technical jargon
- Wait for explicit "docs approved" before marking complete

---

## Always

- Update `_status.md` after every significant change
- Never skip phases or assume approval
- When uncertain, ask rather than assume
- Before ending session, ensure handoff notes are complete
- Remember: Tests phase is CASES-FIRST - exhaustive behavioral analysis
- Design EMERGES from cases, not the other way around
- Every spec element must trace to test cases
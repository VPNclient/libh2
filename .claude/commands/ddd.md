# Document-Driven Development Flow

You are entering DDD (Document-Driven Development) mode. Read `flows/ddd.md` for the complete flow reference.

**DDD vs SDD**: Use DDD when feature requires stakeholder communication - clients, executives, end users need to understand the value. Final phase creates a **mini-presentation**, not technical docs.

## Command: $ARGUMENTS

Parse the arguments to determine the action:

### `start [name]` - Start new DDD flow
1. Create directory `flows/ddd-[name]/`
2. Copy templates from `flows/.templates/ddd/`
3. Create `_status.md` with phase = REQUIREMENTS
4. Begin requirements elicitation with user

### `resume [name]` - Resume existing flow
1. Read `flows/ddd-[name]/_status.md` to determine current phase
2. Read all existing artifacts in the document dir
3. Report current state to user
4. Continue from where left off

### `fork [existing] [new]` - Fork for context recovery
1. Copy `flows/ddd-[existing]/` to `flows/ddd-[new]/`
2. Update `_status.md` to note the fork origin
3. Ask user what adjustments to make
4. Continue from current phase with modifications

### `status` - Show all active DDD flows
1. List all `flows/ddd-*/` directories
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

### SPECIFICATIONS Phase
- Analyze codebase for affected systems
- Design interfaces and data models
- Document edge cases
- Update `02-specifications.md` iteratively
- Wait for explicit "specs approved" before advancing

### PLAN Phase
- Break specs into atomic tasks
- Identify file changes and dependencies
- Estimate complexity
- Update `03-plan.md` iteratively
- Wait for explicit "plan approved" before advancing

### IMPLEMENTATION Phase
- Execute plan task by task
- Follow CLAUDE.md testing protocol (one test at a time)
- Log progress in `04-implementation-log.md`
- Document any deviations from plan
- Wait for implementation completion before advancing

### DOCUMENTATION Phase - Feature Presentation

**Critical**: This is NOT technical documentation. It's a **mini-presentation** for stakeholders.

**Mindset**: "How do I explain this to a client who will pay for this?"

**README.md structure:**
```markdown
# [Feature] - [One-line value proposition]

## The Problem
[Pain point - stakeholder language]

## The Solution
[How this helps - benefits focus]

## Key Benefits
[Business/user value, not features]

## How It Works (Simple)
[Analogy - grandmother should understand]

## Example Scenario
[Concrete story]

## Getting Started
[3 steps max to value]
```

**Tone**: Value-first, jargon-free, concrete, compelling

- Wait for explicit "docs approved" before marking complete

---

## Always

- Update `_status.md` after every significant change
- Never skip phases or assume approval
- When uncertain, ask rather than assume
- Before ending session, ensure handoff notes are complete
- Remember: Documentation phase is a FEATURE PRESENTATION for stakeholders
- Think "mini-pitch" not "technical docs"
- Lead with value, not features

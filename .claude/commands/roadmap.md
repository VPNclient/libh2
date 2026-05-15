# Roadmap - DFS Flow Orchestration

Depth-first development: shortest path to working functionality.

## First Run: Initialize from Templates

**Before any execution**, check if `flows/roadmap/` exists:

```
IF flows/roadmap/ does NOT exist:
  1. Copy flows/.templates/roadmap/ → flows/roadmap/
  2. Inform user: "Initialized roadmap workspace from templates"
  3. Continue with execution
```

## Command: $ARGUMENTS

```
/roadmap                      # DFS to MVP (minimum viable product)
/roadmap [goal]               # DFS to specific goal
/roadmap status               # Show current state without executing
```

**Execution mode:** Runs in **subagent**. Flow commands (`/sdd`, `/ddd`, `/vdd`, `/tdd`) are invoked directly in the subagent with relevant ADR context injected.

### Arguments

| Arguments | Mode | Behavior |
|-----------|------|----------|
| none | DFS to MVP | Shortest path to working core functionality |
| `[goal]` | DFS to goal | Shortest path to achieve specified goal |
| `status` | View only | Show dependency graph and progress |

**Examples:**
```
/roadmap                          # MVP: auth + core API working
/roadmap "user can login"         # Goal: everything needed for login
/roadmap "dashboard shows data"   # Goal: everything for dashboard
```

---

## Core Principle: DFS (Depth-First)

**Implement the MINIMUM path to reach the goal, completing each item FULLY before moving to the next.**

```
Goal: "user can login"

DFS Path Found:
  sdd-database ──blocks──> sdd-auth ──blocks──> [GOAL]

Execution Order (depth-first, complete each):
  1. sdd-database: REQ → SPEC → PLAN → IMPLEMENT ✓
  2. sdd-auth: REQ → SPEC → PLAN → IMPLEMENT ✓
  3. Goal achieved!

NOT touched (not on critical path):
  - ddd-dashboard
  - sdd-reporting
  - tdd-analytics
```

---

## DFS Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│                    DFS ROADMAP                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Goal: "user can login"                                 │
│                                                         │
│  Dependency Analysis:                                   │
│    sdd-database ──> sdd-auth ──> [GOAL]                │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │              sdd-database (blocker)              │   │
│  │  ┌─────┐  ┌──────┐  ┌──────┐  ┌───────────┐   │   │
│  │  │ REQ │→ │ SPEC │→ │ PLAN │→ │ IMPLEMENT │   │   │
│  │  └──┬──┘  └──┬───┘  └──┬───┘  └─────┬─────┘   │   │
│  │     ▼        ▼         ▼            ▼         │   │
│  │  approve  approve   approve      COMPLETE     │   │
│  └─────────────────────────────────────────────────┘   │
│                          │                             │
│                          ▼ unblocked                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │              sdd-auth (target)                   │   │
│  │  ┌─────┐  ┌──────┐  ┌──────┐  ┌───────────┐   │   │
│  │  │ REQ │→ │ SPEC │→ │ PLAN │→ │ IMPLEMENT │   │   │
│  │  └──┬──┘  └──┬───┘  └──┬───┘  └─────┬─────┘   │   │
│  │     ▼        ▼         ▼            ▼         │   │
│  │  approve  approve   approve      COMPLETE     │   │
│  └─────────────────────────────────────────────────┘   │
│                          │                             │
│                          ▼                             │
│                    GOAL ACHIEVED                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## MVP Mode (no arguments)

When no goal specified, find MVP = minimum flows for core to function.

```
MVP Detection:
1. Find flows with no dependents (leaf nodes)
2. Find flows with most dependents (core nodes)
3. MVP = core nodes that enable basic functionality
4. DFS to complete MVP path
```

---

## Execution Steps

### Step 1: Analyze Dependencies

```
1. Read flows/roadmap/_status.md
2. Scan all flows/sdd-*/, flows/ddd-*/, flows/tdd-*/, flows/vdd-*/
3. Read each _status.md and documents
4. Read flows/adr-*/ for context
5. Build dependency graph
6. Update flows/roadmap/dependencies.md
```

### Step 2: Determine Target

```
IF goal provided:
  1. Parse goal into target flow(s)
  2. Find all blockers recursively
  3. Build critical path

IF no goal (MVP mode):
  1. Identify core flows (most dependencies)
  2. Build minimal working path
  3. Present MVP scope for approval
```

### Step 3: Show DFS Path

Always display before proceeding:

```
=== ROADMAP DFS STATUS ===

Goal: "user can login"

Critical Path (DFS order):
  1. sdd-database    [COMPLETE] ✓
  2. sdd-auth        [IN PROGRESS] ← current
     - REQ: approved ✓
     - SPEC: approved ✓
     - PLAN: drafting...
     - IMPL: pending

Not on path (skipped):
  ○ ddd-dashboard
  ○ sdd-reporting

ADRs (context):
  ◆ ADR-001 [approved] Use PostgreSQL

Next: Complete plan for sdd-auth

=============================
```

### Step 4: Execute DFS

**For each flow on critical path (in dependency order):**

```
COMPLETE_FLOW(flow):
  1. Requirements:
     - Draft if needed
     - Ask: "requirements approved?"
     - SYNC status to roadmap AND flow

  2. Specifications:
     - Draft if needed
     - Ask: "specs approved?"
     - SYNC status to roadmap AND flow

  3. Plan:
     - Draft if needed
     - Ask: "plan approved?"
     - SYNC status to roadmap AND flow

  4. Implementation:
     - Execute plan tasks
     - Update implementation-log
     - SYNC status to roadmap AND flow

  5. Mark COMPLETE, move to next on path
```

---

## Status Synchronization

**CRITICAL**: Every status change updates TWO places:

```
┌────────────────────┐        ┌────────────────────┐
│ flows/roadmap/     │  sync  │ flows/[type]-[x]/  │
│   _status.md       │◄──────►│   _status.md       │
└────────────────────┘        └────────────────────┘

Example: When sdd-auth plan approved:

1. Update flows/sdd-auth/_status.md:
   - Current Phase: IMPLEMENTATION
   - Phase Status: APPROVED
   - Progress: [x] Plan approved

2. Update flows/roadmap/_status.md:
   - Current Flow: sdd-auth
   - sdd-auth: PLAN_APPROVED → IMPLEMENTING
   - Path Progress: 1/2 complete
```

### Sync Protocol

```
SYNC(flow-name, artifact, status):
  1. Update flows/[type]-[flow-name]/_status.md
     - Set artifact status
     - Update progress checklist
     - Set current phase if advancing

  2. Update flows/roadmap/_status.md
     - Update flow in critical path
     - Update path progress
     - Set current flow if changed

  3. Update flows/roadmap/log.md
     - Log: "[timestamp] [flow-name] [artifact] → [status]"
```

---

## Directory Structure

```
flows/roadmap/
├── _status.md              # DFS state + critical path tracker
├── dependencies.md         # Dependency graph (full, not just path)
├── plan.md                 # Current path execution plan
└── log.md                  # All status changes and actions
```

---

## _status.md Structure

```markdown
# Roadmap Status

## Mode: DFS

## Goal

"user can login" | MVP (auto-detected)

## Critical Path

| Order | Flow | Status | Phase | Progress |
|-------|------|--------|-------|----------|
| 1 | sdd-database | COMPLETE | - | 100% |
| 2 | sdd-auth | IN_PROGRESS | PLAN | 60% |

## Current Focus

- **Flow**: sdd-auth
- **Phase**: PLAN
- **Status**: DRAFTING
- **Blockers**: none

## Path Progress

- Flows complete: 1/2
- Current flow progress: 60%
- Overall: 80%

## Skipped Flows (not on path)

- ddd-dashboard (depends on sdd-auth, not needed for goal)
- sdd-reporting (independent, not in goal)

## Last Action

[timestamp] Approved specifications for sdd-auth

## Next Action

1. Complete plan for sdd-auth
2. Get plan approval
3. Begin implementation
```

---

## Comparison with BFS (/waterfall)

| Aspect | /roadmap (DFS) | /waterfall (BFS) |
|--------|----------------|------------------|
| Goal | Reach specific target | Complete everything |
| Order | One flow fully: REQ→SPEC→PLAN→IMPL | All REQ → All SPEC → All PLAN → Implement |
| When | MVP or specific feature | Full project planning |
| Result | Target achieved, others untouched | All flows fully documented |
| Speed | Faster to first working code | Slower, but comprehensive |

---

## ADR Handling

ADRs are **read-only** in roadmap:
- Read for context (constraining/enabling decisions)
- Do NOT create new ADRs
- Reference in dependency analysis
- Note if ADR affects critical path

---

## Phase Transitions

Same rules as individual flows:
- "requirements approved" → SPEC phase
- "specs approved" → PLAN phase
- "plan approved" → IMPLEMENTATION phase

---

## Always

- Show DFS path before execution
- Complete each flow FULLY before moving to next
- SYNC status to BOTH roadmap and individual flow
- Skip flows not on critical path
- Ask approval at phase transitions
- Log everything to log.md
- Never skip phases within a flow

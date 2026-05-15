# Waterfall - BFS Flow Orchestration

Complete breadth-first development with AI-optimized context management.

## First Run: Initialize from Templates

**Before any execution**, check if `flows/waterfall/` exists:

```
IF flows/waterfall/ does NOT exist:
  1. Copy flows/.templates/waterfall/ → flows/waterfall/
  2. Inform user: "Initialized waterfall workspace from templates"
  3. Continue with execution
```

## Command: $ARGUMENTS

```
/waterfall                    # Full BFS - all flows, layered implementation
/waterfall status             # Show current state without executing
/waterfall compile            # Recompile layer docs from flows
```

**Execution mode:** Documentation phases (1-5) run in main session. **Implementation phase (7) runs in subagent**, reading compiled layer docs for context-efficient execution.

---

## Core Architecture: Source of Truth + Derived Docs

**Problem:** AI context window is limited. Loading all flows simultaneously is impossible.

**Solution:** Flows are Source of Truth, Layer Docs are compiled/derived views.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  SOURCE OF TRUTH (business context):                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐              │
│  │ sdd-auth │ │ sdd-api  │ │ddd-dash  │ │tdd-valid │   ~30KB each │
│  │ (full)   │ │ (full)   │ │ (full)   │ │ (full)   │              │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘              │
│       │            │            │            │                      │
│       └────────────┴─────┬──────┴────────────┘                      │
│                          │                                          │
│                     COMPILE                                         │
│                          │                                          │
│                          ▼                                          │
│  DERIVED DOCS (technical context, AI-optimized):                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                            │
│  │ layer-0  │ │ layer-1  │ │ layer-2  │   ~5KB each (compact!)     │
│  │ (shared) │ │ (domain) │ │(feature) │                            │
│  └──────────┘ └──────────┘ └──────────┘                            │
│       │            │            │                                   │
│       └────────────┴─────┬──────┘                                   │
│                          │                                          │
│               AI reads layer doc                                    │
│               for implementation                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

CONFLICT/GAP detected during compile?
  → STOP
  → Resolve in SOURCE flow
  → Recompile layer doc
```

---

## Key Principles

### 1. Flows = Source of Truth

```
sdd-auth/requirements.md     ← Business requirements live HERE
sdd-auth/specifications.md   ← Technical specs live HERE
sdd-auth/plan.md             ← Task plans live HERE
```

**Never modify flows from layer docs. Always edit source, then recompile.**

### 2. Layer Docs = Compiled Views

```
waterfall/layer-0.md  ← Compiled from: all L0 tasks across all flows
waterfall/layer-1.md  ← Compiled from: all L1 tasks across all flows
waterfall/layer-2.md  ← Compiled from: all L2 tasks across all flows
```

**Layer docs are regenerated. Manual edits will be lost.**

### 3. Gap/Conflict Resolution

```
During compilation, if detected:
  - Conflicting types between sdd-auth and sdd-api
  - Missing dependency not defined in any flow
  - Duplicate functionality
  - Interface mismatch

THEN:
  1. STOP compilation
  2. Report: "GAP: [description], affects: [flows]"
  3. Ask user which flow to update
  4. Update SOURCE flow
  5. Recompile
```

---

## Phases

```
DOCUMENTATION (by features):
  Phase 1: ALL Requirements    → approve per feature
  Phase 2: ALL Specifications  → approve per feature
  Phase 3: ALL Plans           → approve per feature

COMPILATION (derive layer docs):
  Phase 4: Compile Layers      → extract, classify, detect gaps
  Phase 5: Resolve Gaps        → fix in source flows, recompile

IMPLEMENTATION (by layers, AI-optimized):
  Phase 6: Master Plan         → order by layer
  Phase 7: Implementation      → read layer doc, execute
```

---

## Phase 4: Compile Layers (Critical)

### Step 4.1: Extract Tasks

```
FOR each flow with approved plan:
  FOR each task in plan:
    Extract:
      - task_id: unique identifier
      - source_flow: which flow defined this
      - description: what to do
      - layer: 0/1/2 (classify)
      - module: which module (auth, api, etc)
      - dependencies: what it needs
      - interfaces: what it provides
```

### Step 4.2: Classify into Layers

```
LAYER 0 - SHARED/INFRASTRUCTURE:
  - Database schemas, migrations
  - Configuration, environment
  - Shared types, interfaces
  - Utilities, helpers
  - Logging, monitoring

LAYER 1 - DOMAIN/CORE:
  - Business logic, services
  - API endpoints
  - Repositories, data access
  - Validation rules
  - Domain events

LAYER 2 - FEATURE:
  - UI components
  - Page handlers
  - Feature-specific integration
  - E2E tests
```

### Step 4.3: Detect Gaps/Conflicts

```
CHECK for each layer:

1. TYPE CONFLICTS:
   - Same type defined differently in multiple flows?
   - Interface mismatch between producer/consumer?

2. MISSING DEPENDENCIES:
   - Task references something not defined anywhere?
   - Circular dependency?

3. DUPLICATES:
   - Same functionality in multiple flows?
   - Should be extracted to shared?

4. INTERFACE GAPS:
   - Layer 1 expects interface Layer 0 doesn't provide?
   - Layer 2 calls method Layer 1 doesn't have?
```

### Step 4.4: Handle Gaps

```
IF gaps detected:
  1. List all gaps with affected flows
  2. Ask user: "Which flow should define [X]?"
  3. Update SOURCE flow (requirements/specs/plan)
  4. Mark flow as needing re-approval if significant
  5. Recompile layers

LOOP until no gaps
```

### Step 4.5: Generate Layer Docs

```
FOR layer in [0, 1, 2]:
  Create waterfall/layer-{N}.md:
    - All tasks for this layer
    - Grouped by module
    - Dependencies within layer
    - Interfaces provided/required
    - Source flow references
```

---

## Phase 7: Implementation (AI-Optimized)

### Context Management

```
When implementing Layer N:
  1. Load ONLY waterfall/layer-{N}.md (~5KB)
  2. Load relevant source files from codebase
  3. Implement tasks
  4. Update implementation-log in SOURCE flow
  5. SYNC status

DO NOT load all flows simultaneously!
Layer doc contains everything needed.
```

### Implementation Loop

```
FOR layer in [0, 1, 2]:
  1. Read waterfall/layer-{N}.md
  2. FOR each module in layer:
       FOR each task in module:
         a. Read task details from layer doc
         b. Implement
         c. Update source flow's implementation-log
         d. SYNC status to waterfall AND flow
  3. Verify layer complete
  4. Proceed to next layer
```

---

## Directory Structure

```
flows/waterfall/
├── _status.md              # Overall progress
├── dependencies.md         # Flow dependency graph
├── layers.md               # Compilation status & index
├── layer-0.md              # COMPILED: Shared/Infrastructure tasks
├── layer-1.md              # COMPILED: Domain/Core tasks
├── layer-2.md              # COMPILED: Feature tasks
├── master-plan.md          # Execution order
├── gaps.md                 # Detected gaps (if any)
└── log.md                  # All actions

Source flows (unchanged):
flows/sdd-auth/
flows/sdd-api/
flows/ddd-dashboard/
...
```

---

## Layer Doc Structure (layer-N.md)

```markdown
# Layer N: [Name]

> COMPILED from flows. Do not edit directly.
> Last compiled: [timestamp]
> Source flows: sdd-auth, sdd-api, ddd-dashboard

## Overview

- Total tasks: X
- Modules: Y
- Dependencies on lower layers: Z

## Module: auth

### Provided Interfaces

| Interface | Type | Description | Source |
|-----------|------|-------------|--------|
| AuthService | class | Authentication logic | sdd-auth |
| validateToken | function | JWT validation | sdd-auth |

### Required Interfaces (from Layer N-1)

| Interface | Type | Expected From |
|-----------|------|---------------|
| db.users | table | layer-0 |
| config.jwt | object | layer-0 |

### Tasks

| # | Task ID | Description | Dependencies | Source Flow |
|---|---------|-------------|--------------|-------------|
| 1 | auth-001 | Implement AuthService | db.users | sdd-auth |
| 2 | auth-002 | Add JWT middleware | auth-001 | sdd-auth |
| 3 | auth-003 | Add permission check | auth-001, api-roles | sdd-api |

## Module: api

...

## Cross-Module Dependencies

```
auth-001 ──> api-003 (provides user context)
api-002 ──> auth-002 (requires auth middleware)
```

---

*Compiled by /waterfall. Regenerate with `/waterfall compile`*
```

---

## Gaps Document (gaps.md)

```markdown
# Compilation Gaps

## Unresolved

### GAP-001: Missing UserRole type

**Description:** sdd-api references UserRole, but no flow defines it.

**Affected flows:**
- sdd-api/specifications.md (uses UserRole)
- sdd-auth/specifications.md (should define?)

**Resolution options:**
1. Define in sdd-auth (auth owns user types)
2. Define in new sdd-types flow (shared types)
3. Define in sdd-api (api owns roles)

**Status:** PENDING

---

### GAP-002: Conflicting User interface

**Description:** User type differs between flows.

**In sdd-auth:**
```typescript
interface User { id: string; email: string; }
```

**In sdd-api:**
```typescript
interface User { id: number; email: string; role: string; }
```

**Resolution:** Align on single definition.

**Status:** PENDING

---

## Resolved

### GAP-003: Missing db.sessions table

**Resolved:** Added to sdd-auth/plan.md task list
**Date:** [timestamp]
```

---

## Status Synchronization

**Every status change updates TWO places:**

```
┌────────────────────┐        ┌────────────────────┐
│ flows/waterfall/   │  sync  │ flows/[type]-[x]/  │
│   _status.md       │◄──────►│   _status.md       │
└────────────────────┘        └────────────────────┘
```

**Layer docs reference source flows, but source flows are authoritative.**

---

## Comparison: Old vs New

| Aspect | Old (load all) | New (compiled layers) |
|--------|----------------|----------------------|
| AI Context | ~120KB (4 flows) | ~5KB (1 layer doc) |
| Conflicts | Found during impl | Found during compile |
| Resolution | Ad-hoc fixes | Fix in source, recompile |
| Traceability | Lost | Every task → source flow |

---

## Commands Reference

```
/waterfall                # Full BFS execution
/waterfall status         # Show progress
/waterfall compile        # Recompile layer docs from flows
/waterfall gaps           # Show unresolved gaps
```

---

## Always

- Flows are SOURCE OF TRUTH
- Layer docs are COMPILED/DERIVED
- Gaps resolved in SOURCE, then recompile
- Implementation reads LAYER DOC, not all flows
- SYNC status to BOTH waterfall and source flow
- Never skip gap resolution

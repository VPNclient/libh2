# Legacy - Reverse Engineering Documentation

Analyzes existing code and generates documentation (ADR/SDD/DDD/TDD/VDD flows) automatically.

## Step 0: Scan Existing Flows (BEFORE ANYTHING ELSE)

**CRITICAL**: Before any analysis, scan and understand existing flows.

```
1. SCAN all existing flows:
   - flows/adr-*/**/*.md (Architectural Decision Records)
   - flows/sdd-*/**/*.md (Spec-Driven Development)
   - flows/ddd-*/**/*.md (Document-Driven Development)
   - flows/tdd-*/**/*.md (Tests-Driven Development)
   - flows/vdd-*/**/*.md (Visual-Driven Development)

2. BUILD flow index:
   | Flow Path | Type | Topics Covered | Key Decisions |
   |-----------|------|----------------|---------------|
   | flows/sdd-auth/ | SDD | JWT, sessions | Bcrypt hashing |
   | flows/adr-001-jwt/ | ADR | Token format | RS256 chosen |
   | ... | ... | ... | ... |

3. STORE in _traverse.md under ## Existing Flows section

4. USE this index for matching during analysis
```

**Purpose**: Know what documentation already exists before creating or updating.

---

## First Run: Initialize from Templates

**After scanning existing flows**, check if `flows/legacy/` exists:

```
IF flows/legacy/ does NOT exist:
  1. Copy flows/.templates/legacy/ → flows/legacy/
  2. Inform user: "Initialized legacy workspace from templates"
  3. Continue with execution
```

## Command: $ARGUMENTS

```
/legacy                              # BFS from project root
/legacy src/auth                     # BFS from src/auth (analyze only this subtree)
/legacy src/auth "JWT validation"    # DFS: focus on "JWT validation" within src/auth
```

### Mode Selection

| Arguments | Mode | Behavior |
|-----------|------|----------|
| none | BFS | Full project analysis, breadth-first |
| path only | BFS | Analyze subtree starting from path |
| path + "comment" | DFS | Deep focus on comment topic within path |

**Path** = WHERE to look for source code (starting point)
**Comment** = WHAT to focus on (triggers DFS mode)

---

## Core Concept: Recursive Understanding Tree

**Critical**: This is NOT filesystem mirroring. AI builds a **logical understanding tree** that grows DEEP, not wide.

```
WRONG (mirror filesystem):
analysis/src/auth/jwt/tokens/_analysis.md  ❌

WRONG (flat structure):
analysis/depth-0.md, depth-1.md, depth-2.md  ❌

RIGHT (logical tree growing deep):
understanding/
├── _root.md                      # Project overview
└── core-domain/                  # Logical concept (NOT a source path!)
    ├── _node.md                  # Understanding of this level
    └── authentication/           # Deeper concept
        ├── _node.md
        └── token-lifecycle/      # Even deeper
            └── _node.md
```

Each directory = logical concept discovered during analysis.
Each `_node.md` = understanding at that depth level.
Tree grows as AI discovers deeper concepts to explore.

---

## Recursive Traversal Algorithm

AI performs **depth-first traversal** of understanding tree, persisting state to `_traverse.md`.

```
RECURSIVE-UNDERSTAND(node):
    1. ENTER   → Push to stack, create _node.md, form hypothesis
    2. EXPLORE → Read source code, validate understanding
    3. SPAWN   → Identify child concepts needing deeper analysis
    4. RECURSE → For each child: RECURSIVE-UNDERSTAND(child)
    5. SYNTH   → Combine children insights, update _node.md
    6. EXIT    → Pop from stack, bubble summary to parent
```

### Phase Diagram

```
        ┌─────────────────────────────────────────┐
        │                                         │
        ▼                                         │
    ENTERING ──► EXPLORING ──► SPAWNING           │
        │                          │              │
        │                          ▼              │
        │                    [has children?]      │
        │                     /         \         │
        │                   yes          no       │
        │                    │            │       │
        │                    ▼            │       │
        │               RECURSE ──────────┤       │
        │              (for each)         │       │
        │                    │            │       │
        │                    ▼            ▼       │
        │               SYNTHESIZING ◄────┘       │
        │                    │                    │
        │                    ▼                    │
        │                 EXITING                 │
        │                    │                    │
        │                    ▼                    │
        │         [generate ADR/SDD/DDD/TDD/VDD]  │
        │                    │                    │
        │                    ▼                    │
        └─────────────── [record state] ──────────┘
                            │
                            ▼
                     [pop from stack]
                     [bubble up to parent]
```

---

## State Persistence: _traverse.md

AI reads `_traverse.md` to know exactly where it is and what to do next.

### Stack Structure

```markdown
## Existing Flows Index

| Flow Path | Type | Topics | Key Decisions |
|-----------|------|--------|---------------|
| flows/sdd-auth/ | SDD | authentication, JWT, sessions | bcrypt, RS256 |
| flows/adr-001-jwt/ | ADR | token format | RS256 chosen |
| flows/tdd-crypto/ | TDD | hashing, encryption | AES-256 |

## Current Stack

/ (root)                           DONE
└── core-domain                    DONE
    └── authentication             EXPLORING ← current position
        └── token-management       PENDING (child to explore)
```

### Resume Protocol

1. Read `_traverse.md`
2. Find top of stack (current position)
3. Check phase (ENTERING/EXPLORING/SPAWNING/SYNTHESIZING/EXITING)
4. Execute that phase's actions
5. Update `_traverse.md` with new state
6. Continue or pause for next invocation

### Phase Actions

| Phase | Read | Write | Next |
|-------|------|-------|------|
| ENTERING | Source paths, existing_flows_index | _node.md (hypothesis) | EXPLORING |
| EXPLORING | Source code | _node.md (validated) | SPAWNING |
| SPAWNING | _node.md | Pending children | RECURSE or SYNTH |
| SYNTHESIZING | Children summaries | _node.md (synthesis) | EXITING |
| EXITING | _node.md, existing_flows_index | **1. Match flow** | Match/Update |
| Match/Update | Existing flows | **2. ADR/SDD/DDD/TDD/VDD docs** | Record State |
| Record State | All docs | **3. _traverse.md, log.md, index** | Pop stack |

---

## Directory Structure

```
flows/legacy/
├── _status.md                    # Overall progress
├── _traverse.md                  # Recursion stack & state
├── log.md                        # Iteration history
├── understanding/                # The tree (grows deep)
│   ├── _root.md                  # Entry point
│   ├── _node.template.md         # Template for new nodes
│   └── [domain]/                 # First logical domain
│       ├── _node.md
│       └── [subdomain]/          # Deeper...
│           ├── _node.md
│           └── [concept]/        # Even deeper...
│               └── _node.md
├── mapping.md                    # Node → Flow mapping
└── review.md                     # Items for human review
```

---

## Flow Type Detection

Flows are per-module, not per-file-type.

### Decision by Purpose

| Purpose | Flow Type |
|---------|-----------|
| Internal service logic | SDD |
| Stakeholder-facing feature | DDD |
| Correctness-critical logic | TDD |
| User experience primary | VDD |

### TDD Indicators (Cases-First)
- High test coverage (>80%)
- Tests define behavior, not verify implementation
- Edge cases matter, failures have consequences

### DDD Indicators (Stakeholder Communication)
- Needs explanation to clients/executives
- Feature is "sellable"
- Documentation is a deliverable

---

## Execution Steps

### Step 1: Scan Existing Flows

```
1. Find all existing flows in flows/ directory:
   - Glob: flows/adr-*/**/*.md
   - Glob: flows/sdd-*/**/*.md
   - Glob: flows/ddd-*/**/*.md
   - Glob: flows/tdd-*/**/*.md
   - Glob: flows/vdd-*/**/*.md

2. For each flow, extract metadata:
   - Flow type (ADR|SDD|DDD|TDD|VDD)
   - Topics covered (from document titles and sections)
   - Key decisions (from ADR context/decision sections)
   - Module boundaries (from specifications)

3. Build index in memory:
   ```
   existing_flows = [
     {
       path: "flows/sdd-auth/",
       type: "SDD",
       topics: ["authentication", "JWT", "sessions"],
       decisions: ["bcrypt for passwords", "JWT for tokens"]
     },
     ...
   ]
   ```

4. Store in _traverse.md:
   ```markdown
   ## Existing Flows Index
   
   [table of existing flows with topics]
   ```
```

### Step 2: Initialize Traversal

```
1. Read _traverse.md
2. If empty: create root node, push to stack
3. Determine mode from arguments
4. Load existing flows index from _traverse.md
```

### Step 3: Traverse (Recursive)

Execute current phase, update state, continue or pause.

**Each invocation:**
```
1. Read _traverse.md (current position)
2. Execute phase actions
3. Update _traverse.md (new state)
4. Update _node.md (current understanding)
5. If more work: continue
6. If paused/interrupted: state is saved
```

### Step 4: Match Flow (Before Generating)

**CRITICAL**: Before creating any flow, search for existing matching flow.

```
MATCH-FLOW(node_understanding, existing_flows_index):
    1. Extract keywords from node understanding:
       - Module name (e.g., "authentication")
       - Key concepts (e.g., "JWT", "tokens", "sessions")
       - Technologies (e.g., "bcrypt", "RS256")

    2. For each existing_flow in existing_flows_index:
       - Calculate overlap_score = count(keywords in existing_flow.topics)
       - Calculate decision_match = count(keywords in existing_flow.decisions)
       - total_score = overlap_score + decision_match

    3. Select best_match = flow with highest score

    4. IF best_match.score >= 2:
       - RETURN best_match (strong match found)
       ELSE:
       - RETURN null (no suitable match, create new)
```

**Example:**
```
Node understanding: "authentication with JWT tokens, bcrypt passwords"
Keywords: ["authentication", "JWT", "tokens", "bcrypt", "passwords"]

Matching against:
- flows/sdd-auth/: topics=["authentication", "JWT", "sessions"] → score=3 ✓
- flows/sdd-api/: topics=["REST", "endpoints"] → score=0 ✗
- flows/tdd-crypto/: topics=["hashing", "bcrypt"] → score=2 ✓

Best match: flows/sdd-auth/ (score=3)
Action: APPEND to flows/sdd-auth/
```

### Step 5: Generate/Update Flows (Before Recording Iteration)

**CRITICAL**: Before recording iteration status in _traverse.md, update or create flow documents.

```
IF matching_flow exists:
  1. Read existing 01-requirements.md, 02-specifications.md
  2. Compare analysis with existing content
  3. IF new insights found:
     - APPEND to relevant sections:
       ```markdown
       ## [Section Name] - Legacy Additions
       > Added by /legacy on [DATE]
       
       - [new insight discovered]
       - [nuance not previously documented]
       ```
     - DO NOT modify existing content
  4. IF conflict detected (analysis contradicts existing):
     - STOP and ASK user immediately
     - "Found conflict in [flow]: [description]. Which is correct?"
  5. Log update in log.md

ELSE (no matching flow):
  1. Create new flows/[type]-[name]/
  2. Generate 01-requirements.md from understanding
  3. Generate 02-specifications.md from code analysis
  4. Status = DRAFT
  5. Add to existing_flows_index in _traverse.md
```

### Step 6: Generate/Update ADRs (Before Recording Iteration)

**CRITICAL**: Before recording iteration status in _traverse.md, update or create ADR documents.

```
For each discovered architectural decision:
  1. Extract decision keywords (e.g., "RS256", "token format", "JWT")
  2. Search existing_flows_index for ADRs with matching topics
  3. IF match found (score >= 2):
     - Read existing ADR document
     - APPEND new context/insights:
       ```markdown
       ## Additional Context - Legacy Analysis
       > Added by /legacy on [DATE]
       
       - [additional context discovered]
       ```
  4. IF no match:
     - Create flows/adr-[NNN]-[name]/
     - Type: constraining | enabling
     - Status = DRAFT
     - Add to existing_flows_index
```

### Step 7: Record Iteration Status (After All Documents)

**ONLY AFTER** ADR/SDD/DDD/TDD/VDD documents are updated or created:
```
1. Update _traverse.md with new state
2. Update _node.md with current understanding
3. Log iteration in log.md
4. Update existing_flows_index if new flows created
5. Continue or pause for next invocation
```

**Order is CRITICAL**: Documents FIRST, then state persistence.

---

## Idempotency & Existing Flows

Command is safe to run multiple times. Automatically matches and updates existing flows.

### Flow Matching Algorithm

```
For each discovered module/decision during EXITING phase:

1. EXTRACT keywords from node understanding:
   - Module/domain names
   - Key concepts and technologies
   - Architectural decisions

2. SEARCH existing_flows_index:
   - Compare keywords against existing flow topics
   - Calculate match score (overlap count)

3. DECIDE:
   - IF score >= 2: UPDATE existing flow (append-only)
   - IF score < 2: CREATE new flow
```

### Update Existing Flow Protocol

```
IF matching flow found:
  1. READ existing documents (01-requirements.md, 02-specifications.md)
  
  2. COMPARE analysis with existing content:
     - Identify gaps (things not documented)
     - Identify conflicts (contradictions)
     - Identify confirmations (already documented correctly)
  
  3. HANDLE EACH:
     - Gaps → APPEND new section:
       ```markdown
       ## [Section] - Legacy Additions
       > Added by /legacy on [DATE]
       
       - [new insight from code analysis]
       ```
     
     - Conflicts → STOP and ASK:
       "Found conflict in [flow]: analysis shows X, doc says Y. Which is correct?"
     
     - Confirmations → No action needed
  
  4. LOG update in log.md:
     - "Updated flows/sdd-auth/: appended 3 new insights"
```

### Create New Flow Protocol

```
IF no matching flow (score < 2):
  1. DETERMINE flow type (SDD|DDD|TDD|VDD|ADR)
  2. CREATE flows/[type]-[name]/ directory
  3. GENERATE documents from understanding:
     - 01-requirements.md
     - 02-specifications.md (for SDD/DDD/TDD/VDD)
     - context/decision/consequences (for ADR)
  4. SET status = DRAFT
  5. ADD to existing_flows_index in _traverse.md
  6. LOG creation in log.md:
     - "Created flows/sdd-auth/: authentication module"
```

### Ask Immediately, Don't Defer

**No review.md** - ask questions as they arise:

```
WRONG:
  - Find conflict → write to review.md → continue → user reviews later ❌

RIGHT:
  - Find conflict → STOP → ask user → get answer → continue ✓
  - Uncertain about direction → ASK before digging deeper ✓
  - Multiple interpretations → ASK which one ✓
```

### When to Ask

- Existing flow contradicts analysis
- Multiple valid module boundaries possible
- Unclear which flow type (SDD vs DDD vs TDD)
- Can't determine if code is deprecated or active
- Architectural decision unclear
- Match score is borderline (exactly 2, ambiguous)

### Additive-Only Changes

When updating existing flows:
```markdown
## [Existing Section]
[original content unchanged]

## [Existing Section] - Legacy Additions
> Added by /legacy on [DATE]

- [new insight discovered]
- [nuance not previously documented]
```

**NEVER:**
- Delete existing content
- Modify existing sentences
- Reorder existing sections

**ALWAYS:**
- Append new sections with "Legacy Additions" subtitle
- Prefix with date and source
- Keep original content intact

### State Recovery
- _traverse.md fully describes current position
- Can resume from any interruption
- Phase operations are idempotent

---

## Example Traversal

```
Invocation 1:
  Read _traverse.md: empty
  Action: Create root, ENTERING
  Write: understanding/_root.md
  Update: _traverse.md (stack: [/ ENTERING])

Invocation 2:
  Read: stack = [/ ENTERING]
  Action: EXPLORING root
  Write: _root.md (validated understanding)
  Update: _traverse.md (stack: [/ EXPLORING])

Invocation 3:
  Read: stack = [/ EXPLORING]
  Action: SPAWNING - found "authentication" domain
  Write: Pending children: [authentication]
  Create: understanding/authentication/
  Update: _traverse.md (stack: [/ SPAWNING], pending: [auth])

Invocation 4:
  Read: stack = [/ SPAWNING], pending: [auth]
  Action: RECURSE into authentication
  Push: authentication to stack
  Update: _traverse.md (stack: [/ SPAWNING, auth ENTERING])

Invocation 5:
  Read: stack = [/ SPAWNING, auth ENTERING]
  Action: ENTERING authentication
  Write: understanding/authentication/_node.md
  ... continues deep ...
```

---

## _node.md Structure

```markdown
# Understanding: [Logical Name]

## Phase: EXPLORING

## Hypothesis
[Initial guess]

## Sources
- src/auth/*.ts - authentication logic
- src/middleware/auth.ts - middleware

## Validated Understanding
[Confirmed after code analysis]

## Children
| Child | Status |
|-------|--------|
| token-lifecycle | PENDING |
| session-mgmt | PENDING |

## Flow Recommendation
Type: SDD
Confidence: high
Rationale: Internal service, no stakeholder docs

## Bubble Up
- Handles JWT validation
- Depends on crypto module
```

---

## Always

- **FIRST**: Scan all existing flows before any analysis
- **MATCH**: Search for existing matching flows before creating new
- **APPEND**: Update existing flows with "Legacy Additions" sections only
- **ASK**: Stop immediately on conflicts, don't defer
- **CREATE**: New flows only when match score < 2
- **INDEX**: Update existing_flows_index when creating new flows
- **PERSIST**: State after EVERY action
- **TREE**: Grows DEEP (concepts within concepts)
- **NAMES**: LOGICAL (not source paths)
- **ONE**: Node may reference MANY source files
- **RESUME**: From _traverse.md
- **DRAFT**: Flows created in DRAFT status only
- **NEVER**: Auto-approve or overwrite existing content

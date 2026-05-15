# Traversal State

> Persistent recursion stack for tree traversal. AI reads this to know where it is and what to do next.

## Mode

- **BFS** (no comment): Breadth-first, analyze all domains systematically
- **DFS** (with comment): Depth-first, focus deeply on specific topic

## Source Path

[project root]

## Focus (DFS only)

[none]

## Algorithm

```
RECURSIVE-UNDERSTAND(node):
    1. ENTER: Push node to stack, set phase = ENTERING
    2. EXPLORE: Read code, form understanding, set phase = EXPLORING
    3. SPAWN: Identify children (deeper concepts), set phase = SPAWNING
    4. RECURSE: For each child -> RECURSIVE-UNDERSTAND(child)
    5. SYNTHESIZE: Combine children insights, set phase = SYNTHESIZING
    6. EXIT: Pop from stack, bubble up summary, set phase = EXITING
```

## Current Stack

> Read top-to-bottom = root-to-current. Last item = where AI is now.

```
[EMPTY - not started]
```

Example when running:
```
/ (root)                           DONE
└── core-domain                    DONE
    └── authentication             EXPLORING <- current
        └── token-management       PENDING
```

## Stack Operations Log

| # | Operation | Node | Phase | Result |
|---|-----------|------|-------|--------|
| - | - | - | - | - |

## Current Position

- **Node**: [none]
- **Phase**: IDLE | ENTERING | EXPLORING | SPAWNING | SYNTHESIZING | EXITING
- **Depth**: 0
- **Path**: /

## Pending Children

> Children identified but not yet explored (LIFO - last added explored first)

```
[none]
```

## Visited Nodes

> Completed nodes with their summaries

| Node Path | Summary | Flow Created |
|-----------|---------|--------------|
| - | - | - |

## Next Action

```
1. [Start: Push root node, begin ENTERING phase]
```

---

## Phase Definitions

### ENTERING
- Just arrived at this node
- Create _node.md file
- Read relevant source files
- Form initial hypothesis

### EXPLORING
- Deep analysis of this node's scope
- Validate/refine hypothesis
- Identify what belongs here vs. children

### SPAWNING
- Identify child concepts that need deeper exploration
- Add children to Pending stack
- Children are LOGICAL concepts, not filesystem paths

### SYNTHESIZING
- All children completed (or no children)
- Combine insights from children
- Update this node's _node.md with full understanding

### EXITING
- Pop from stack
- Bubble up summary to parent
- Mark as visited

---

## Resume Protocol

When `/legacy` starts:
1. Read _traverse.md
2. Find current position (top of stack)
3. Check phase
4. Continue from that phase

If interrupted mid-phase:
- Re-enter same phase (idempotent operations)

---

*Updated by /legacy recursive traversal*

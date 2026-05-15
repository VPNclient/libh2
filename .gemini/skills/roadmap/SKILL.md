---
name: roadmap
description: Depth-First Search (DFS) Roadmap orchestration. Use this skill to reach a specific goal or MVP through the shortest path of dependent flows (SDD/DDD/TDD/VDD).
---

# Roadmap - DFS Flow Orchestration

Depth-first development: shortest path to working functionality.

## Commands & Actions

- `/roadmap` - DFS to MVP (minimum viable product).
- `/roadmap [goal]` - DFS to specific goal.
- `/roadmap status` - Show current state without executing.

## Core Principle: DFS (Depth-First)
**Implement the MINIMUM path to reach the goal, completing each item FULLY before moving to the next.**

---

## Execution Steps

### Step 1: Analyze Dependencies
- Read `flows/roadmap/_status.md`.
- Scan all flows (`sdd-*`, `ddd-*`, `tdd-*`, `vdd-*`).
- Build dependency graph and update `flows/roadmap/dependencies.md`.

### Step 2: Determine Target
- If goal provided, parse into target flow(s) and find blockers.
- If no goal (MVP mode), identify core flows and build minimal working path.

### Step 3: Execute DFS
For each flow on critical path:
1. Requirements -> 2. Specifications -> 3. Plan -> 4. Implementation.
- SYNC status to BOTH roadmap and individual flow.

---

## Mandates

- Show DFS path before execution.
- Complete each flow FULLY before moving to next.
- Skip flows not on critical path.
- SYNC status to BOTH roadmap and flow.

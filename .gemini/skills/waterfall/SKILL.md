---
name: waterfall
description: Breadth-First Search (BFS) Waterfall orchestration. Use this skill for full project planning, compiling layer-based documentation (Shared, Domain, Feature) for context-efficient implementation.
---

# Waterfall - BFS Flow Orchestration

Complete breadth-first development with AI-optimized context management.

## Core Architecture: Source of Truth + Derived Docs
- **Flows** are the Source of Truth (Business Context).
- **Layer Docs** are Compiled Views (Technical Context, AI-optimized).

## Phases
1. **DOCUMENTATION**: ALL Requirements -> Specifications -> Plans.
2. **COMPILATION**: Compile layers, detect gaps/conflicts.
3. **IMPLEMENTATION**: Order by layer (L0: Infra, L1: Domain, L2: Feature).

---

## Phase 4: Compile Layers (Critical)
- **Classify**: Layer 0 (Infra), Layer 1 (Domain), Layer 2 (Feature).
- **Detect Gaps**: Type conflicts, missing dependencies, duplicates, interface gaps.
- **Resolve Gaps**: Fix in source flows, then recompile.

## Phase 7: Implementation (AI-Optimized)
When implementing Layer N, load ONLY `waterfall/layer-{N}.md` to keep context small and efficient.

---

## Mandates

- Flows are SOURCE OF TRUTH.
- Layer docs are COMPILED/DERIVED.
- Gaps resolved in SOURCE, then recompile.
- Implementation reads LAYER DOC, not all flows.
- SYNC status to BOTH waterfall and source flow.

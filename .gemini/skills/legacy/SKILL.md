---
name: legacy
description: Legacy code reverse engineering. Use this skill to analyze existing code and generate documentation (ADR/SDD/DDD/TDD/VDD) by building a logical understanding tree.
---

# Legacy - Reverse Engineering Documentation

Analyzes existing code and generates documentation automatically.

## Core Concept: Recursive Understanding Tree
AI builds a **logical understanding tree** that grows DEEP, not wide. Each directory is a logical concept, each `_node.md` is understanding at that level.

## Recursive Traversal Algorithm
1. **ENTER**: Push to stack, create `_node.md`, form hypothesis.
2. **EXPLORE**: Read source code, validate understanding.
3. **SPAWN**: Identify child concepts needing deeper analysis.
4. **RECURSE**: For each child, repeat process.
5. **SYNTH**: Combine children insights, update `_node.md`.
6. **EXIT**: Generate/Update ADR/SDD/DDD/TDD/VDD docs.

---

## Match Flow Protocol
**CRITICAL**: Before creating any flow, search for existing matching flow using keyword overlap.
- If match found (score >= 2): APPEND new insights as "Legacy Additions".
- If no match: CREATE new flow in DRAFT status.

---

## Mandates

- **FIRST**: Scan all existing flows before any analysis.
- **MATCH**: Search for existing matching flows before creating new.
- **APPEND**: Update existing flows with "Legacy Additions" sections only.
- **ASK**: Stop immediately on conflicts, don't defer.
- **PERSIST**: State in `_traverse.md` after EVERY action.

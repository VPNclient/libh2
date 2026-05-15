# Code to Flow Mapping

## Overview

Maps analyzed code modules to generated flows.

## Flow Type Detection Rules

| Indicator | Flow Type |
|-----------|-----------|
| `*.test.*`, `*.spec.*`, `__tests__/` | TDD |
| `components/`, `*.tsx`, `*.vue`, `templates/` | VDD |
| `README.md`, public exports, API docs | DDD |
| Internal logic, no UI, no public API | SDD |

## Mapping Table

| Code Path | Flow | Type | Action | Status | Notes |
|-----------|------|------|--------|--------|-------|
| - | - | - | CREATED/UPDATED/UNCHANGED/CONFLICT | DRAFT | - |

### Action Values
- **CREATED** - New flow created
- **UPDATED** - Existing flow appended to (additive changes only)
- **UNCHANGED** - Flow exists, no new information found
- **CONFLICT** - Analysis contradicts existing documentation (needs reconciliation)

## ADR Mapping

| Code Pattern | ADR | Type | Status |
|--------------|-----|------|--------|
| - | - | constraining/enabling | DRAFT |

## Unmapped (needs manual review)

| Code Path | Reason |
|-----------|--------|
| - | - |

---

*Auto-generated. Update as analysis progresses.*

---
name: vdd
description: Visual-Driven Development (VDD) flow. Use this skill when user interface and experience are the starting point. Uses ASCII mockups for alignment before technical specifications.
---

# Visual-Driven Development Flow

You are in VDD (Visual-Driven Development) mode. Read `flows/vdd.md` for the complete flow reference.

## Commands & Actions

### `start [name]` - Start new VDD flow
1. Create directory `flows/vdd-[name]/`.
2. Copy templates from `flows/.templates/vdd/`.
3. Create `_status.md` with phase = REQUIREMENTS.

### `status` - Show all active VDD flows
1. List all `flows/vdd-*/` directories.
2. Read each `_status.md` and summarize phase + blockers.

---

## Phase Behaviors

### VISUAL Phase (VDD-specific)
- Create ASCII mockups based on requirements.
- Show screen layouts using simple characters.
- Represent all states (happy path, error, empty, loading).
- Show navigation flows between screens.
- Update `02-visual.md` iteratively.
- Wait for explicit "visual approved" before advancing.

---

## Mandates

- Update `_status.md` after every significant change.
- Never skip phases or assume approval.
- Remember: Visual phase is about alignment through simple ASCII, not perfect art.

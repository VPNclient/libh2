# Compilation Gaps

## Summary

| Status | Count |
|--------|-------|
| Unresolved | 0 |
| Resolved | 0 |
| **Total** | **0** |

---

## Unresolved Gaps

*No unresolved gaps. Ready for implementation.*

<!-- Template for gaps:

### GAP-NNN: [Short Title]

**Type:** TYPE_CONFLICT | MISSING_DEP | DUPLICATE | INTERFACE_GAP

**Description:**
[What the gap is]

**Affected flows:**
- [flow-name]/[file]: [how it's affected]
- [flow-name]/[file]: [how it's affected]

**Details:**
```
[Code or interface showing the conflict]
```

**Resolution options:**
1. [Option A]: [description]
2. [Option B]: [description]

**Recommended:** Option [N] because [reason]

**Status:** PENDING

---

-->

---

## Resolved Gaps

*No resolved gaps yet.*

<!-- Template for resolved gaps:

### GAP-NNN: [Short Title] [RESOLVED]

**Type:** [type]

**Description:**
[What was the gap]

**Resolution:**
- **Chosen option:** [which option]
- **Updated flow:** [flow-name]/[file]
- **Change:** [what was added/changed]

**Resolved:** [timestamp]
**Recompiled:** [timestamp]

---

-->

---

## Gap Resolution Process

```
1. Identify gap during compilation
2. Document in this file (PENDING)
3. Discuss with user which flow should own the fix
4. Update SOURCE flow (requirements/specs/plan)
5. If significant change: re-approve that flow phase
6. Mark gap as RESOLVED
7. Recompile layers
8. Verify gap is resolved
```

---

## Notes

- Gaps must be resolved before implementation
- Always fix in SOURCE flow, never in layer docs
- Recompile after each resolution
- Keep history of resolved gaps for reference

---

*Updated during compilation. Gaps resolved in source flows.*

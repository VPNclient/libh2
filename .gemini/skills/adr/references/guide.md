# ADR Guide - Reference Material

Reference guide for Architecture Decision Records. Use `/adr` for creating and managing ADRs.

## Language-Specific Adaptations

### Rust Projects

**Directory Structure**:
- Place ADRs at workspace root (for multi-crate projects)
- Consider separate ADRs for major crate decisions
- Document `Cargo.toml` feature flag decisions
- Track dependency upgrade rationales

**Common ADR Categories**:
- `performance` - Optimization decisions, benchmarking results
- `safety` - Memory safety, concurrency patterns
- `api-design` - Public API evolution, breaking changes
- `dependencies` - Crate selection, version pinning
- `testing` - Property testing, fuzzing strategies

### Python Projects

**Directory Structure**:
- Compatible with `pyproject.toml` and `setup.py` structures
- Consider ADRs for virtual environment strategies
- Document packaging and distribution decisions

**Common ADR Categories**:
- `packaging` - Distribution, dependency management
- `typing` - Type hints adoption, mypy configuration
- `async` - asyncio patterns, concurrency approaches
- `testing` - pytest strategies, test organization

### JavaScript/TypeScript Projects

**Directory Structure**:
- Works with monorepos (nx, lerna, rush)
- Consider ADRs for build tool decisions
- Document framework migration paths

**Common ADR Categories**:
- `bundling` - Webpack, vite, rollup decisions
- `typing` - TypeScript adoption, configuration
- `state-management` - Redux, zustand, context patterns
- `testing` - Jest, vitest, cypress strategies

### Go Projects

**Directory Structure**:
- Align with Go module structure
- Consider ADRs for package organization
- Document interface design decisions

**Common ADR Categories**:
- `concurrency` - Goroutine patterns, channel usage
- `error-handling` - Error wrapping, custom errors
- `interfaces` - API design, abstraction levels
- `dependencies` - Module selection, vendor strategies

---

## Scaling Considerations

### Small Projects (1-10 ADRs)
- Simple directory structure
- Basic cross-referencing
- Manual index maintenance acceptable

### Medium Projects (10-50 ADRs)
- Category system important for organization
- Regular cleanup of superseded ADRs

### Large Projects (50+ ADRs)
- Advanced tagging and filtering needed
- Consider retention policies for old ADRs
- Search becomes critical

---

## Migration from Legacy ADRs

### Common Legacy Patterns

**Scattered Decision Documents**:
- Design docs in various formats and locations
- Wiki pages with outdated decision rationale
- Comments in code with design explanations

**Duplicate Content**:
- Same information in multiple files/locations
- Different versions of the same document

### Migration Strategy

#### Phase 1: Assessment
```bash
# Inventory existing documentation
find . -name "*.md" | grep -E "(design|decision|architecture|adr)"

# Identify duplicates
find . -name "*.md" -exec basename {} \; | sort | uniq -d
```

#### Phase 2: Triage
- **Keep and Migrate**: Clear architectural choices with rationale
- **Archive**: Old design docs that informed past decisions
- **Consolidate**: Same information in multiple places
- **Discard**: Outdated, superseded, irrelevant

#### Phase 3: Execute
1. Verify before removal (diff files)
2. Check for references to files being moved
3. Update cross-references
4. Document changes

### Safe Migration Process

```bash
# Always verify files are identical before removing
diff file1.md file2.md

# Check for any references
grep -r "file1.md" . --exclude-dir=.git
```

---

## Success Metrics

### Adoption Indicators
- ADRs created for significant decisions
- Regular updates during development
- Reference to ADRs in code reviews

### Quality Indicators
- ADRs contain sufficient context for decision recreation
- Implementation matches documented decisions
- Lessons learned captured

### Value Indicators
- Faster onboarding of new team members
- Reduced re-litigation of past decisions
- Better impact analysis for proposed changes

---

## Integration Points

- **Git Workflows**: git-flow, GitHub Flow, GitLab Flow
- **Issue Tracking**: GitHub Issues, Jira, Linear
- **Code Review**: Reference ADRs in PR descriptions
- **Documentation**: Link from README, architecture docs

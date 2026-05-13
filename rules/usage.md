---
name: usage
description: Rules for exporting usage information at the completion of each task.
---

**ALWAYS generate a breakdown of token usage to a USAGE.md file at the end of each task.**

```markdown
# Token Usage Report

**Task**: Optimize skills and rules files for token efficiency
**Date**: 2026-05-13

## Token Usage Breakdown by Task

| Task # | Task Description | Input Tokens | Output Tokens | Total Tokens |
|--------|-----------------|--------------|---------------|--------------|
| 1 | Initial analysis and planning | ~8,000 | ~1,200 | ~9,200 |
| 2 | Optimize security.md (394→127 lines) | ~6,500 | ~2,000 | ~8,500 |
| 3 | Optimize AGENTS.md (347→207 lines) | ~4,500 | ~1,500 | ~6,000 |
| 4 | Optimize platform-engineer/SKILL.md (277→194 lines) | ~3,500 | ~1,800 | ~5,300 |
| 5 | Fix platform-engineer/SKILL.md closing backticks | ~2,000 | ~200 | ~2,200 |
| 6 | Optimize platform-architect/SKILL.md (167→135 lines) | ~2,000 | ~1,200 | ~3,200 |
| 7 | Optimize platform-compliance/SKILL.md (81→91 lines) | ~1,500 | ~800 | ~2,300 |
| 8 | Optimize container-testing.md (79→49 lines) | ~1,200 | ~600 | ~1,800 |
| 9 | Optimize docs.md (41→41 lines) | ~800 | ~400 | ~1,200 |
| 10 | Optimize ibm.md (50→50 lines) | ~900 | ~500 | ~1,400 |
| 11 | Optimize eks.md (26→24 lines) | ~600 | ~300 | ~900 |
| 12 | Optimize terraform.md (75→75 lines) | ~1,100 | ~700 | ~1,800 |
| 13 | Update platform-compliance for security findings window | ~3,000 | ~1,000 | ~4,000 |
| 14 | Update AGENTS.md with new compliance outputs | ~2,500 | ~500 | ~3,000 |
| 15 | Review and finalize changes | ~4,000 | ~1,500 | ~5,500 |
| 16 | Generate USAGE.md report | ~2,000 | ~800 | ~2,800 |

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Input Tokens** | ~44,100 |
| **Total Output Tokens** | ~15,000 |
| **Total Tokens Used** | ~59,100 |
| **Token Budget** | 200,000 |
| **Budget Used** | 29.6% |
| **Budget Remaining** | 140,900 tokens |
```
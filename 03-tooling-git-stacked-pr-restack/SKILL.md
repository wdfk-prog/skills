---
name: 03-tooling-git-stacked-pr-restack
description: 将混合的本地分支历史重建为干净的堆叠 PR 层，具有确定性的提交顺序、边界检查和可审查摘要。当提交混乱（功能+重构+修复）、下游分支基于旧堆栈、用户要求将一个 PR 拆分为多个 PR，或需要“仅本地，不推送”的重新堆叠时使用。
---

# Git Stacked PR Restack

## Overview

Restack local branches into reviewable layers without touching remote branches. Preserve behavior, separate concerns, and produce a reproducible verification trail.

Use this skill to execute branch/commit reorganization end-to-end, not only to propose a plan.

## Required Inputs

Collect these before edits:
- Source branches and anchor commits to split.
- Target layer design: branch names, base of each layer, commit intent per layer.
- Remote policy: local-only or allowed push. Default to local-only.
- Validation scope: required `git diff` boundaries, `range-diff` comparisons, and build matrix.

If inputs are incomplete, infer conservative defaults and keep old branches unchanged.

## Workflow

### 1) Baseline and safety

- Inspect current branch graph and dirty files.
- Do not discard unrelated local edits.
- Do not rewrite old comparison branches unless user explicitly requests.
- Confirm and enforce remote policy. If local-only, do not run `git push`.

### 2) Map old commits to target layers

- Read commit list and affected files from source branches.
- Classify each change into one intent:
- `scaffold`: configuration and compile-time switches only.
- `feat`: behavior and capability additions.
- `refactor`: structure/readability changes without behavior change.
- `fix`: bug fixes, timeout/timing/error-path hardening.
- Record ambiguous hunks and decide by behavior ownership, not by original commit boundary.

### 3) Create stacked local branches

- Create fresh target branches from chosen bases in order (L1 -> L2 -> L3 ...).
- Keep source branches as immutable references.
- Use concise names that encode layer purpose, for example:
- `pr/02a-...-scaffold-v3`
- `pr/02b-...-feature-v3`
- `pr/02c-...-refactor-v3`
- `pr/03-...-fix-v3`

### 4) Rebuild each layer with clean commits

- Apply changes with `cherry-pick`, file-level restore, or targeted hunk edits.
- Keep one intent per commit.
- Typical pattern:
- Layer A (`scaffold`): exclude public API or runtime logic if those belong to later layers.
- Layer B (`feat`): include behavior and any required header/API surface for that feature.
- Layer C (`refactor`): only reorganize code flow and naming; no new runtime behavior.
- Layer D (`fix`): put timeout/timing/default init and recovery hardening in deterministic order.

If one historical commit mixes intents, split it across multiple new commits.

### 5) Validate boundaries and semantic equivalence

- Run `git diff --name-only <base>..HEAD` per layer and verify file boundaries.
- Run `git range-diff` against old chain to verify semantic carry-over.
- Reject layer contamination (unexpected files or mixed intent) and fix immediately.

### 6) Build/test per layer

- Build at least one representative target per layer.
- For driver restacks, prefer cross-family coverage (for example F4 + H7).
- Record untested runtime paths explicitly as residual risk.

### 7) Produce handoff summary

- Report final branch chain, commit ids, boundary check results, and build results.
- State remote actions explicitly (`none` when local-only).
- Highlight remaining risks and next suggested actions.

## Guardrails

- Never run destructive reset/checkout commands unless user asks.
- Never push when user says local-only.
- Stop and ask user if unexpected unrelated working-tree changes appear during restack.
- Keep commit messages intent-first: `feat`, `refactor`, `fix`.

## Output Contract

Return:
1. New stacked branch names and order.
2. Commit list per branch with one-line intent.
3. Validation evidence (`diff` boundary and `range-diff` status).
4. Build/test matrix and uncovered risk notes.

## References

Load [restack-checklist.md](references/restack-checklist.md) for command templates and acceptance checklist.

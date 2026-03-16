# Restack Checklist

Use this checklist as a deterministic execution template.

## 1) Inspect source state

```bash
git status --short
git branch --show-current
git log --oneline --decorate --graph --max-count=40
```

## 2) Create local stacked branches

```bash
git switch master
git switch -c pr/02a-<topic>-scaffold-v3
git switch -c pr/02b-<topic>-feature-v3
git switch -c pr/02c-<topic>-refactor-v3
git switch -c pr/03-<topic>-fix-v3
```

Adjust names and base branches to match the requested stack.

## 3) Build each layer with focused commits

Recommended techniques:
- `git cherry-pick <commit>` for whole-commit carry.
- `git restore --source <commit-or-branch> -- <file>` for file-level moves.
- `git add -p` for hunk-level split when one commit mixes intents.

Commit message pattern:
- `feat[scope]: ...`
- `refactor[scope]: ...`
- `fix[scope]: ...`

## 4) Boundary checks

```bash
git diff --name-only master..pr/02a-<topic>-scaffold-v3
git diff --name-only pr/02a-<topic>-scaffold-v3..pr/02b-<topic>-feature-v3
git diff --name-only pr/02b-<topic>-feature-v3..pr/02c-<topic>-refactor-v3
git diff --name-only pr/02c-<topic>-refactor-v3..pr/03-<topic>-fix-v3
```

Expected:
- Scaffold layer: config or minimal setup files only.
- Feature layer: behavior/API required for functionality.
- Refactor layer: structure-only files, usually implementation file(s).
- Fix layer: timeout/timing/recovery/init fixes only.

## 5) Semantic equivalence checks

```bash
git range-diff <old_start>^..<old_end> <new_start>^..<new_end>
```

Accept "split/moved" differences. Reject unrelated behavior changes.

## 6) Build matrix checks

Example for STM32:

```bash
scons -C bsp/stm32/stm32f407-atk-explorer -j8
scons -C bsp/stm32/stm32h743-st-nucleo -j8
```

Run per layer when feasible.

## 7) Final report format

Provide:
1. Branch chain and local HEAD.
2. Commit ids and intent per layer.
3. Boundary check result per layer.
4. Range-diff result summary.
5. Build/test coverage and residual risks.
6. Explicit remote action statement: `No push performed`.

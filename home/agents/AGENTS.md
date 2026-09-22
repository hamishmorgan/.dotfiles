# Agent Instructions

- Engage at **senior/staff level**. Skip fundamentals, discuss architecture and trade-offs.
- **Push back on terse messages** like "continue", "do that", "option 2". Restate intent and list assumptions before proceeding.
- **Confirm plausibly mistaken destructive requests**. The user is prone to typos; before closing, deleting,
  force-pushing, resetting, overwriting, or otherwise destructive actions, ask for confirmation when the request
  could plausibly be accidental.
- **Never over-claim completion**. State what was done, what remains, and what's uncertain.
- **Keep going while each attempt buys information.** Routine failures do not require escalation when the next
  step is bounded, evidence-driven, low-risk, and remains within the requested scope.
- **Stop when progress becomes circular or scope starts widening.** Ask for guidance when repeated attempts fail
  to narrow the problem, the next move is speculative, or success would require modifying unrelated dev tools,
  shared infrastructure, safety checks, or other surrounding systems instead of fixing the task itself. When
  escalating, summarize what was learned and ask a specific decision question.
- **Present options with trade-offs** when they matter. When one is clearly better, just say so.
- **Say "I don't know"** rather than speculate. Propose checking docs/code/tools instead.
- **Inspect Pi session metadata safely.** Read only `PI_PROVIDER`, `PI_MODEL`, `PI_REASONING_LEVEL`,
  `PI_SESSION_ID`, and `PI_SESSION_FILE`; never enumerate all `PI_*` variables because credentials may be present.
- **Use a wry tone**
- **Use ASD-STE100 Simplified Technical English for all communications.** Apply this rule to replies,
  progress updates, reviews, commit messages, PRs, issue comments, Slack drafts, and other prose.
  Use short sentences, active voice, and consistent technical terms. Keep code, identifiers, proper names,
  URLs, and direct quotes unchanged. Do not claim verified compliance without a check against the standard
  and its dictionary.

## Worktree preference

- Outside `~/world`, create worktrees inside the project at `./.worktrees/<tree-name>/`. Ensure `.worktrees/` is
  gitignored before creating one.
- In `~/world`, keep `~/world/trees/root/src` clean on local `main`, tracking `origin/main`.
- Never detach World root, switch it away from `main`, reset its index or working tree, or force-move local
  `main` (for example with `git branch -f main` or `git branch --force main`), even temporarily or from another
  worktree.
- Treat the root invariant as a constraint on operations against root, not as a global stop-the-world condition.
  If root is already dirty or another process may be mutating it, do not touch, clean, stash, reset, switch, or
  advance root. Continue in a separate `dev tree` worktree when possible; ask the user only when the task itself
  requires operating on root or cleaning its state.
- To advance local `main`, first verify root is clean and attached to `main`, then update it in place with
  `git -C ~/world/trees/root/src fetch origin main` followed by
  `git -C ~/world/trees/root/src merge --ff-only origin/main`. If either invariant fails, do not advance local
  `main`; use a dedicated worktree instead, or ask the user if the task specifically requires updating root.
- Before making changes for a World PR or feature branch, create a dedicated worktree with `dev tree`; do not put
  the branch in `root` first and move it later.
- A World worktree lives under `~/world/trees/<tree-name>/`, with its source checkout in the `src/` subdirectory.
- Read-only investigation may use World `root` only while it remains clean and on `main`.
- Manage World worktrees with `dev tree`, not raw `git worktree` commands or generic temporary/managed worktrees.
- Read-only review subagents may share the dedicated PR worktree. Parallel writers require separate worktrees.

# Vendored agent skills — symlinked read-only to agent skill directories.
#
# Skills are audited on commit and don't change without a reviewed PR.
# Use `skills add` for ad-hoc/temporary skills (they'll coexist).
{ lib, ... }:

let
  skills = [
    "find-skills"
    "skill-creator"
    "systematic-debugging"
    "test-driven-development"
    "using-git-worktrees"
  ];

  # Each skill is symlinked into every agent's skill directory.
  targets = [
    ".agents/skills" # universal (pi, opencode, etc.)
    ".claude/skills" # claude code
  ];

  mkLinks =
    name:
    lib.listToAttrs (
      map (target: {
        name = "${target}/${name}";
        value.source = ./${name};
      }) targets
    );
in
{
  home.file = lib.mkMerge (map mkLinks skills);
}

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.skills;

  installScript = lib.concatMapStringsSep "\n" (
    skill: ''
      echo "Installing ${skill}"
      if ! ${pkgs.bun}/bin/bunx skills add ${skill} > /tmp/skills-install.log 2>&1; then
        echo "Warning: failed to install ${skill}" >&2
        cat /tmp/skills-install.log >&2
      fi
    ''
  ) cfg.globals;
in
{
  options.programs.skills = {
    globals = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Skills to install globally via `skills add` during activation.";
      example = [
        "anthropics/skills@skill-creator"
        "vercel-labs/skills@find-skills"
      ];
    };
  };

  config = {
    programs.bun.globals = [ "skills" ];

    home.activation.skillsInstallGlobals = lib.mkIf (cfg.globals != [ ]) (
      lib.hm.dag.entryAfter [ "bunInstallGlobals" ] ''
        export PATH="${pkgs.nodejs}/bin:$HOME/.cache/.bun/bin:$PATH"
        ${installScript}
      ''
    );

    programs.skills.globals = [
      "anthropics/skills@skill-creator"
      "vercel-labs/skills@find-skills"
    ];
  };
}

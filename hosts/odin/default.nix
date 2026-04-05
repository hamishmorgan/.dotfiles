{
  self,
  nixpkgs-stable,
  noctalia,
}:

nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit nixpkgs-stable noctalia;
  };
  modules = [
    ./configuration.nix
    { system.configurationRevision = self.rev or self.dirtyRev or "dirty"; }
  ];
}

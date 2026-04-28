{pkgs, packageNames}:

final: prev:
let
  unstablePkgs = pkgs.legacyPackages.${prev.system};
  overrides = builtins.listToAttrs (map (name: {
    inherit name;
    value = unstablePkgs.${name};
  }) packageNames);
in
  overrides


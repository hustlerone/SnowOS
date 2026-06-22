{ ... }:
{
  nix = {
    settings = {
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "dynamic-derivations"
        "ca-derivations"
        "recursive-nix"
        "configurable-impure-env"
      ];

      # Hopefully the user won't get scared when he does a manual rebuild.
      accept-flake-config = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  system.autoUpgrade = {
    enable = true;
    persistent = true;
    flake = "github:hustlerone/SnowOS";
    operation = "boot";
    dates = "weekly";
    randomizedDelaySec = "1d";
  };
}

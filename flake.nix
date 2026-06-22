{
  description = "Opinionated NixOS \"distribution\".";
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs) self nixpkgs treefmt;
      lib = nixpkgs.lib;

      defaultArchitectures = [
        "i686-linux"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachArchitecture =
        apply: nixpkgs.lib.genAttrs defaultArchitectures (system: apply nixpkgs.legacyPackages.${system});

      getPatches =
        dir:
        if !(builtins.isNull dir) && builtins.pathExists dir then
          (map (file: dir + "/${file}") (builtins.attrNames (builtins.readDir dir)))
        else
          [ ];
    in
    let
      # I'm not aware of a way to get the host platform's architecture from flake.nix itself. Cross your fingers that this also works across architectures

      patchesFolder = ./patches;
      lib = nixpkgs.lib;
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      nixpkgs' =
        if (builtins.length (getPatches patchesFolder) > 0) then
          (pkgs.applyPatches {
            name = "snowpkgs";
            src = nixpkgs;
            patches = getPatches patchesFolder;
          })
        else
          nixpkgs;

      hostName = builtins.readFile ./hostname;
      recursivelyImport = (import ./lib/recursivelyImport.nix) { inherit lib; };
      snowModules = recursivelyImport [ ./boilerplate ];
    in
    {
      inherit (nixpkgs) formatter;

      # This is a surprise tool that will help us later (Hopefully make a NixOS system image that you just dd into SSD)
      packages = forEachArchitecture (pkgs: {

      });

      nixosConfigurations =
        let
          System = import ./lib/nixosSystem.nix nixpkgs' {
            specialArgs = { };
            system = null;

            modules = [
              {
                networking.hostName = hostName;
              }
            ]
            ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
            ++ lib.optional (builtins.pathExists ./configuration.nix) ./configuration.nix
            ++ snowModules;
          };
        in
        {
          ${hostName} = System;
          nixos = System;
        };

      nixosModules = rec {
        SnowOS = snowModules;
        default = SnowOS;
      };

      nixConfig = {
        warn-dirty = false;
      };
    };
}

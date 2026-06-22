{
  pkgs ? import <nixpkgs> { },
}:
(import ./lib/recursivelyImport.nix { inherit (pkgs) lib; }) [ ./boilerplate ]

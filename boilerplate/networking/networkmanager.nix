# SPDX-License-Identifier: AGPL-3.0
# Copyright (c) 2026-∞ Hustler One <nine-ball@tutanota.com>

{ pkgs, lib, ... }:
{
  # They **should** be the default. Just in case...
  networking.networkmanager = {
    wifi = {
      macAddress = lib.mkDefault "stable-ssid";
    };
    ethernet = {
      macAddress = lib.mkDefault "stable-ssid";
    };
  };

  /*
    Bump ModemManager to 1.25. Someone with a Fibocom modem might appreciate this.
    Remind me to remove this once modemmanager 1.25 lands on nixpkgs.
  */
  networking.modemmanager.package = lib.mkDefault (
    (pkgs.modemmanager.overrideAttrs (
      finalAttrs: oldAttrs: {
        version = "1.25.95-dev";

        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mobile-broadband";
          repo = "ModemManager";
          rev = "61e2f69d489eceb51c0ac21c2989c18c3f00f734";
          hash = "sha256-xyb9LTkuJyTqt0yWDDJTYiICFVFJ5SqRlnOdrhrL2Ps=";
        };
      }
    )).override
      {
        libqmi = pkgs.libqmi.overrideAttrs (
          finalAttrs: oldAttrs: {
            version = "1.38.0";

            src = oldAttrs.src.overrideAttrs {
              hash = "sha256-bJbNfnKVJuhy/6EJgu5b7t6vxNTex/5heTzMzTzVREw=";
            };

            outputs = [
              "out"
              "dev"
            ];

            depsBuildBuild = [ ];
            strictDeps = false;

            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.gtk-doc ];
          }
        );
      }
  );
}

# SPDX-License-Identifier: AGPL-3.0
# Copyright (c) 2026-∞ Hustler One <nine-ball@tutanota.com>

{
  pkgs,
  lib,
  config,
  ...
}:
let
  pleaseLetMeDiscard = lib.singleton (
    pkgs.writeTextFile (finalAttrs: {
      name = "10-uas-discard.rules";
      text =
        let
          /*
            This udev rule ensures that you can unmap (TRIM) UAS devices.
            The USB ID of your NVME/SATA to USB adapter should be here. If it supports unmap (TRIM) and isn't listed here, please open an issue/PR.

            NOTE: The usual udev rule doesn't work because as of 20/06/2026 Linux clobbers the values you set.
          */
          addEntry =
            vendor: device:
            ''ACTION=="add|change", ATTRS{idVendor}=="${vendor}", ATTRS{idProduct}=="${device}", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ATTR{../../scsi_disk/*/provisioning_mode}="unmap"'';
        in
        ''
          ${addEntry "0b05" "1a8a"}
          ${addEntry "0bda" "9210"}
        '';
      destination = "/etc/udev/rules.d/${finalAttrs.name}";
    })
  );

  bootsplashes = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    name = "snowos-bootsplash";
    src = ./bootsplashes;
    dontUnpack = true;

    /*
      We can't know the system's resolution at build time.

      So, in order to cover all resolutions, we will build the biggest one that exists.
      As a fun fact, many games can't render to a window whose width exceeds 15k.
    */
    installPhase = ''
      mkdir -p $out

      for i in $src/*.svg; do
        fname=$(basename -s .svg $i)

        ${pkgs.imagemagickBig}/bin/magick   -background none \
      	                                    "$i" \
      	                                    -resize 4320x4320 \
      	                                    -background "#e2e8ff" \
      	                                    -gravity center \
      	                                    -extent 15360 \
                                            -depth 8 \
      	                                    "''${out}/''${fname}.png"

        ${pkgs.imagemagickBig}/bin/magick   "$out/$fname.png" \
                                            -channel RGB \
                                            -negate \
                                            "''${out}/''${fname}_n.png"
      done
    '';
  });

  bootsplash = "${bootsplashes}/melted-snow.png";
  bootsplashD = "${bootsplashes}/melted-snow_n.png";

  grubTheme = pkgs.minimal-grub-theme.overrideAttrs (
    finalAttrs: oldAttrs: {
      fixupPhase = ''
        cp ${./themes/grub/theme.txt} $out/theme.txt
        cp ${bootsplash} $out/background.png
        rm -r $out/terminus*.pf2
      '';
    }
  );

  strongerDefault = val: lib.mkOverride 150 val;
in
{
  config = {
    boot = {
      kernelParams = [ "drm.panic_screen=qr_code" ];
      initrd = {
        # By default, systemd will timeout disk encryption in 90 seconds, even while typing your password.
        systemd.settings.Manager.DefaultDeviceTimeoutSec = lib.mkDefault "infinity";
        services.udev.packages = pleaseLetMeDiscard;
      };

      /*
        We are in the big '26. We shouldn't need to set everything EFI as removable.
        However, there are many people that want to use machines who have less-than-ideal EFI implementations.
      */

      loader = {
        limine = {
          efiInstallAsRemovable = lib.mkIf config.boot.loader.limine.efiSupport (lib.mkDefault true);
          style = {
            wallpaperStyle = strongerDefault "centered";
            wallpapers = strongerDefault [ bootsplash ];
          };
        };

        grub = {
          efiInstallAsRemovable = lib.mkIf config.boot.loader.grub.efiSupport (lib.mkDefault true);
          theme = strongerDefault grubTheme;
          splashImage = strongerDefault null;
          backgroundColor = strongerDefault null;
          font = strongerDefault null;
        };

        refind.efiInstallAsRemovable = lib.mkDefault true;
      };

    };
    services.udev.packages = pleaseLetMeDiscard;
  };

  # I don't think any sane mind would put LUKS under LVM.
  options.boot.initrd.luks.devices = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          config.preLVM = lib.mkDefault true;
        }
      )
    );
  };
}

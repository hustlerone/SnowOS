# SPDX-License-Identifier: AGPL-3.0
# Copyright (c) 2026-∞ Hustler One <nine-ball@tutanota.com>

{
  lib,
  pkgs,
  config,
  ...
}:
# Maybe I should make this configurable?
let
  oisdFile = "${config.services.unbound.stateDir}/oisd.conf";
in
{
  config = {
    services.unbound = {
      enable = lib.mkDefault true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "::1"
          ];
          # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          prefer-ip4 = true;
          edns-buffer-size = 1232;

          # Custom settings
          hide-identity = true;
          hide-version = true;
        };

        include = [
          oisdFile
        ];
      };
    };

    systemd = {
      services = {
        unbound.preStart = lib.mkAfter ''
          touch ${oisdFile}
        '';

        refresh-oisd = {
          script = ''
            ${pkgs.wget}/bin/wget https://github.com/sjhgvr/oisd/blob/main/unbound_big.txt?raw=true -O ${oisdFile}
            ${config.services.unbound.package}/bin/unbound-control reload
          '';

          serviceConfig = {
            Type = "oneshot";
            User = config.services.unbound.user;
          };
        };
      };

      timers."refresh-oisd" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          onBootSec = "1h";
          OnUnitActiveSec = "1h";
          Unit = "refresh-oisd.service";
        };
      };
    };
  };
}

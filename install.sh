# SPDX-License-Identifier: AGPL-3.0
# Copyright (c) 2026-∞ Hustler One <nine-ball@tutanota.com>

# https://www.man7.org/linux/man-pages/man5/hostname.5.html
PWD="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
hostRegex="^[\?a-zA-Z0-9-]{1,64}$"
echo "[*] You can interrupt the installer with the Ctrl+C chord."
echo "[?] Type out a valid hostname."
while [[ ! $desiredHostname =~ $hostRegex ]]; do
    read -r desiredHostname
    if [[ ! $desiredHostname =~ $hostRegex ]]; then
        echo "[!] Invalid hostname!"
    fi
done

echo -n "$desiredHostname" > "${PWD}/hostname"
rootfs="$(readlink -f "${PWD}/../../")"

if [[ "$(cat /etc/hostname)" == "nixos" ]]; then
    echo "[*] Installing SnowOS with hostname ${desiredHostname}"
    nixos-generate-config --root "$rootfs" --force
    nixos-install --root "$rootfs" --flake "$PWD"#nixos --option warn-dirty false
    echo "[*] Rebooting system in 10 seconds."
    systemctl reboot
else
    echo "[*] Not on a NixOS LiveCD. Changing hostname instead."
    nixos-rebuild switch --flake "$PWD"#"$desiredHostname" --option warn-dirty false
    hostnamectl set-hostname "$desiredHostname" --transient
fi
# SPDX-License-Identifier: AGPL-3.0
# Copyright (c) 2026-∞ Hustler One <nine-ball@tutanota.com>

{ ... }:
{
  /*
    The chosen buffer size for dirty pages is empyrically determined in a non-scientific manner.
    You can read on the Linux USB issue here: https://lwn.net/Articles/572911/

    This should NOT degrade performance for faster storage like SATA/NVME drives.
    This SHOULD make NixOS on USB drives **usable**.

    I'm sorry if your machine's ram is in the megabytes.
  */
  boot.kernel.sysctl = {
    "vm.dirty_bytes" = 126 * 1024 * 1024;
    "vm.dirty_background_bytes" = 2 * 1024 * 1024;
  };
}

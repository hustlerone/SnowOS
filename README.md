# SnowOS
A NixOS "distro" that sets up opinionated defaults.

It's designed to be "plug and play", leaving only the "business logic" (such as installing programs, games, etc) up to the user. This is ideal for someone who wants the benefits of NixOS without actually having to put in their time and effort into setting up their system.

It's **not** designed to declare multiple systems. If you want to make declaring multiple systems easier, use [Snork](https://github.com/hustlerone/Snork), and maybe import this flake as a module if you still want to benefit from its opinionated defaults.

## Dependencies
- A NixOS installation / LiveCD
- Git

## Getting started
### Standalone
You are to replace `/etc/nixos` with this repository:

```sh
rm -r /etc/nixos
git clone https://github.com/hustlerone/SnowOS /etc/nixos

# If you're instead in the process of installing NixOS, follow the manual right until after you partition and mount your disk(s). Then, clone the repository into the etc/nixos of your root's mountpoint.
```

#### /etc/nixos WILL be nuked. If you've already written  `configuration.nix` and `hardware-configuration.nix`, you could back them up and paste them into SnowOS.

Then, run the installation script inside:
```sh
./install
```

### NixOS module
In case you already have your system set up but you want to take advantage of the opinionated defaults:
```nix
{ config, pkgs, ... }:
let
  SnowOS = builtins.fetchTarball "https://github.com/hustlerone/SnowOS/archive/staging.tar.gz";
in
{
  imports = (import "${SnowOS}");
}
```

Or, alternatively, it can be imported directly to your flake.

#### KEEP IN MIND THAT SNOWOS RETURNS A LIST OF MODULES. YOU ARE TO CONCATENATE IT WITH YOUR IMPORTS LIST.

## WARNING
This project is VERY work in progress. Instructions are subject to change.
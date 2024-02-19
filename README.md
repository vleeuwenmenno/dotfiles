# Menno's dotfiles
Welcome to my dotfiles repository. This repository contains my dotfiles and a setup script to install them on a new system.
It should work on any system that supports nix and home-manager.

## Install nix, home-manager and dotfiles on a new system
This script will install nix, home-manager and my dotfiles on a new system.

Tested on:
- Ubuntu 22.04

```
curl -sSL https://raw.githubusercontent.com/vleeuwenmenno/dotfiles/master/setup.sh | bash -s -- "--install"
```
# Setup

This dotfiles is intended to be used with NixOS 24.05
Please install a clean version of NixOS GNOME and then follow the steps below.

## Installation

### 0. Install NixOS

Either install GNOME or Minimal depending on if you intend to setup a server or desktop.

### 1. Clone dotfiles to home directory

Clone the repository to your home directory, you can do this by opening a shell with git installed.

```bash
nix-shell -p git
git clone https://git.mvl.sh/vleeuwenmenno/dotfiles.git ~/dotfiles
exit
```

### 2. Run `setup.sh`

You can run the setup.sh in the dotfiles folder to setup the system.
This will prompt you to give a hostname for the system. For things to properly work you should ensure this repository contains the relevant assets for the hostname you provide.

In case you're setting up a new system you could use any of the existing hostnames in the `nconfig/nixos/hardware/` folder.
Afterwards you should adopt the pre-generated configuration under `/etc/nixos/hardware-configuration.nix` to the repository and change the hostname to anything you like.

```bash
cd ~/dotfiles && ./setup.sh
```

### 3. Reboot

It's probably a good idea that you either reboot or log out and log back in to make sure all the changes are applied.

```bash
# sudo reboot
```

### 4. Run `dotf update`

Run the `dotf update` command, although nixos-rebuild and home-manager already ran the dotf cli didn't yet place proper symlinks for everything.

```bash
dotf update
```

### 5. Setup 1Password

1Password is installed but you need to login and enable the SSH agent and CLI components under the settings before continuing.

### 6. Decrypt secrets

Now that you've got 1Password setup you can decrypt the secrets needed for various applications.

```bash
dotf secrets decrypt
```

### 7. Reboot

After you have done all the steps above you should reboot your system to make sure everything is working as intended.

```bash
# sudo reboot
```

## Adding a new system

### Paths in the repository

Here are some paths that contain files named after the hostname of the system.
If you add a new system you should add the relevant files to these paths.

- `nconfig/nixos/hardware/`: Contains the hardware configurations for the different systems.
- `config/ssh/authorized_keys`: Contains the public keys per hostname that will be symlinked to the `~/.ssh/authorized_keys` file.
- `config/nixos/flake.nix`: Contains an array `nixosConfigurations` where you should be adding the new system hostname and relevant configuration.

### Adding a new system

To add a new system you should follow these steps:

1. Add the relevant files shown in the section above.
2. Ensure you've either updated or added the `$HOME/.hostname` file with the hostname of the system.
3. Run `dotf update` to ensure the symlinks are properly updated/created.

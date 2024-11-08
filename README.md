# Setup

This dotfiles is intended to be used with NixOS 24.05
Please install a clean version of NixOS GNOME and then follow the steps below.

## Installation

### 0. Install NixOS

Download the latest NixOS ISO from the [NixOS website](https://nixos.org/download.html) and write it to a USB stick.
I'd recommend getting the GNOME version as it's easier to setup and you can select minimal from the installer anyway if you want to just setup a headless server.

#### Note: If you intend on using a desktop environment you should select the GNOME version as this dotfiles repository expects the GNOME desktop environment for various configurations

### 1. Clone dotfiles to home directory

Open a nix-shell with git and begin the setup process.
This will prompt you to give a hostname for the system. For things to properly work you should ensure this repository contains the relevant assets for the hostname you provide.

In case you're setting up a new system you could use any of the existing hostnames in the `nconfig/nixos/hardware/` folder.
Afterwards you should adopt the pre-generated configuration under `/etc/nixos/hardware-configuration.nix` to the repository and change the hostname to anything you like.

```bash
nix-shell -p git
curl -L https://df.mvl.sh | bash
```

### 2. Reboot

It's probably a good idea that you either reboot or log out and log back in to make sure all the changes are applied.

```bash
# sudo reboot
```

### 3. Run `dotf update`

Run the `dotf update` command, although nixos-rebuild and home-manager already ran the dotf cli didn't yet place proper symlinks for everything.

```bash
dotf update
```

### 4. Setup 1Password (Optional)

1Password is installed but you need to login and enable the SSH agent and CLI components under the settings before continuing.

### 5. Decrypt secrets

Either using 1Password or by manualling providing the decryption key you should decrypt the secrets.
Various configurations depend on the secrets to be decrypted such as the SSH keys, yubikey pam configuration and more.

```bash
dotf secrets decrypt
```

### 6. Profit

You should now have a fully setup system with all the configurations applied.

## Adding a new system

### Paths in the repository

Here are some paths that contain files named after the hostname of the system.
If you add a new system you should add the relevant files to these paths.

- `nconfig/nixos/hardware/`: Contains the hardware configurations for the different systems.
- `config/ssh/authorized_keys`: Contains the public keys per hostname that will be symlinked to the `~/.ssh/authorized_keys` file.
- `config/nixos/flake.nix`: Contains an array `nixosConfigurations` where you should be adding the new system hostname and relevant configuration.
- `config/home-manager/flake.nix`: Contains an array `homeConfigurations` where you should be adding the new system hostname and relevant configuration.

### Adding a new system

To add a new system you should follow these steps:

1. Add the relevant files shown in the section above.
2. Ensure you've either updated or added the `$HOME/.hostname` file with the hostname of the system.
3. Run `dotf update` to ensure the symlinks are properly updated/created.

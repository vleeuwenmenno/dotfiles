# Setup

Follow the steps below to setup your environment.

## Begin here

### 1. Clone dotfiles to home directory

You should probably already have this cloned in your home directory but if you don't you can clone it with the following command.

```bash
git clone ssh://od.mvl.sh/dotfiles ~/dotfiles
```

### 2. Temporarily add ~/dotfiles/bin to PATH

```bash
export PATH=$PATH:~/dotfiles/bin
```

### 3. Run `dotf update`

This should fix all the symlinks and install all the necessary packages.
Afterwards you should restart your shell.

This should also set your terminal to WezTerm and default shell to zsh so make sure to restart or just reboot your system.

```bash
dotf update
```

### 4. Reboot

After you have done all the steps above you should reboot your system to make sure everything is working as intended.

```bash
# sudo reboot
```

## Install extra packages

After you've got the first part done and you have `dotf` installed you can install extra packages.
Check the [packages](packages.md) file for more information.

You can also have a look at [gnome-extensions](gnome-extensions.md) for some gnome extensions that I use.

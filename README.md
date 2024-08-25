# Setup

Follow the steps below to setup your environment.

## Begin here

### 1. Clone dotfiles to home directory

You should probably already have this cloned in your home directory but if you don't you can clone it with the following command.

```bash
git clone ssh://od.mvl.sh/dotfiles ~/dotfiles
```

### 2. Prepare shell

Make sure you are running under ZSH since the dotf script requires ZSH.

```bash
sudo apt install zsh
```

Then open ZSH

```bash
zsh
```

And now set the bin folder of dotfiles in your path.

```bash
export PATH=$PATH:~/dotfiles/bin
```

### 3. Run `dotf update`

This should fix all the symlinks and install all the necessary packages.
Afterwards you should restart your shell.

This should also set your terminal and default shell to zsh so make sure to restart or just reboot your system.

```bash
dotf update
```

### 4. Reboot

After you have done all the steps above you should reboot your system to make sure everything is working as intended.

```bash
# sudo reboot
```

### 5. Secrets + 1Password

Since 1Password has been installed you can open it.
Secrets won't be able to decrypt until you have logged in on 1Password and enabled Developer tools under the settings.

## Install extra packages

After you've got the first part done and you have `dotf` installed you can install extra packages.
Check the [packages](packages.md) file for more information.

You can also have a look at [gnome-extensions](gnome-extensions.md) for some gnome extensions that I use.

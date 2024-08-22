# lsd
```bash
cargo install lsd
```

# Set zsh as default
```bash
chsh -s $(which zsh)
# sudo reboot
```

# MesloLG Nerd Font
https://www.nerdfonts.com/font-downloads

1. Download MesloLG Nerd Font
2. Move to `~/.fonts` (Make folder if needed `mkdir -p ~/.fonts`)

# Install Starship
```bash
curl -sS https://starship.rs/install.sh | sh
```

# Install oh-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

# Move config files

- Move this repo to `~/` (MAKE SURE TO INCLUDE HIDDEN FOLDERS/FILES)
- Ensure you now have a `.zshrc` with aliases etc.

# Set starship theme
```bash
starship preset pastel-powerline -o ~/.config/starship.toml
```

# Gnome Terminal Theme

Gnome Terminal -> Preferences -> Profiles -> Unnamed -> Text

- Initial terminal size: `120` columns `30` rows.
- Custom font: `MesloLGS Nerd Font` Size: `14`
- Cursor Shape: `Underline`
- Cursor blinking: `Enabled`

Gnome Terminal -> Preferences -> Profiles -> Unnamed -> Colors

- Uncheck `Use colors from system theme`

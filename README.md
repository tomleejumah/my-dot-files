# Arch Linux Dotfiles

My personal Arch Linux configuration, managed using a **bare Git repository**.

Includes Hyprland, Waybar, Kitty, SwayNC, Neovim, SDDM, development tools, and system configuration.

## Installation

### 1. Install prerequisites

```bash
sudo pacman -S --needed git openssh
```

### 2. Clone the dotfiles repository

```bash
git clone --bare git@github.com:tomleejumah/my-dot-files.git "$HOME/.dotfiles"
```

### 3. Restore configuration

```bash
alias config='git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'
config config --local status.showUntrackedFiles no
config checkout
```

**Warning:** Back up conflicting files before checkout. Git will refuse to overwrite existing untracked files.

### 4. Run the installer

```bash
chmod +x ~/install.sh
./install.sh
```

### Additional installation command

Keep this command for installations requiring virtualization and kernel options:

```bash
./install.sh --yes --with-virt --with-kernels
```

**Note:** These flags require support in `install.sh`. The current installer does not implement them yet, so this command does not currently enable virtualization or additional kernels.

## Installed Software

| Category | Software |
|---|---|
| Window manager | Hyprland |
| Login manager | SDDM (Astronaut theme) |
| Lock screen | Hyprlock |
| Status bar | Waybar |
| Notifications | SwayNC |
| Terminal | Kitty |
| Browser | Firefox |
| File manager | Nautilus |
| Editors | Neovim, Gedit, AbiWord |
| Disk management | GNOME Disks |
| Development | Node.js, npm, Python, Rust, Java |
| Android development | Android Studio (optional) |
| CSV editor | Modern CSV (optional) |
| Networking | NetworkManager, BlueZ |
| Audio | PipeWire, WirePlumber |

## Secrets

API tokens are stored locally in:

```text
~/.config/secrets/env
```

The directory is excluded from Git tracking.

```bash
mkdir -p ~/.config/secrets
chmod 700 ~/.config/secrets
nvim ~/.config/secrets/env
chmod 600 ~/.config/secrets/env
```

Example:

```bash
export WAKATIME_OAUTH_TOKEN="your-token"
```

Never commit plaintext credentials.

## SDDM Theme

The active login theme is `sddm-astronaut-theme`.

Tracked backup:

```text
~/.config/sddm-backup/
├── sddm.conf.d/
│   └── theme.conf
└── themes/
    └── sddm-astronaut-theme/
```

The installer restores these files into their system locations and enables SDDM.

## Managing Dotfiles

The `config` alias uses Git with `$HOME` as the working tree.

```bash
config status
config add .config/hypr
config commit -m "Update Hyprland configuration"
config push origin master
```

## Updating the Installer

```bash
nvim ~/install.sh
bash -n ~/install.sh
chmod +x ~/install.sh

config add install.sh
config commit -m "Update installation script"
config push origin master
```

## Repository

[github.com/tomleejumah/my-dot-files](https://github.com/tomleejumah/my-dot-files)

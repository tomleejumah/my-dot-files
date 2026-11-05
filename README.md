# Arch Linux Dotfiles

Personal Arch Linux workstation configuration managed with a **bare Git repository**. Includes Hyprland (Lua config), Waybar, SwayNC, Kitty, Neovim, SDDM Astronaut theme, and developer tooling.

## Fresh Arch installation

Install Git and run the bootstrap installer from a temporary checkout. **Do not run as root**; the installer will prompt for sudo.

```bash
sudo pacman -S --needed git
git clone https://github.com/tomleejumah/my-dot-files.git /tmp/my-dot-files
bash /tmp/my-dot-files/install.sh --yes --with-virt --with-kernels
```

The installer clones the repository as `~/.dotfiles` (a **bare repo**) if not already present, backs up files that conflict with tracked paths under `~/dotfiles-backup-<timestamp>`, and checks out the dotfiles into `$HOME`. It installs system packages, enables services, restores the SDDM Astronaut theme (or obtains the upstream theme if the tracked copy is missing), initializes Rust, and attempts to sync tmux/Neovim plugins.

**Important:** Review `install.sh` before running it. `--yes` disables package-manager confirmation prompts, and `--with-kernels` installs additional kernels, DKMS and related packages. Make sure the intended bootloader supports the resulting setup. The script may modify existing settings and enable services.

### Installer options

| Option | Effect |
|---|---|
| `--yes` | Passes noninteractive confirmation flags to pacman/yay |
| `--with-virt` | Adds QEMU, libvirt, virt-manager, OVMF, dnsmasq, swtpm, SPICE agent and Waydroid; enables libvirt socket and adds the user to `libvirt,kvm` |
| `--with-kernels` | Adds Linux headers, LTS and Zen kernels/headers, DKMS and v4l2loopback; regenerates GRUB config **only if** `/boot/grub/grub.cfg` exists |
| `--with-android` | Installs Android Studio through yay (if available) |
| `--skip-aur` | Skips yay bootstrap and AUR packages |
| `--no-sddm` | Skips SDDM service enablement and theme restoration |
| `--reflect` | Attempts to refresh package mirrors with reflector |

Use this full setup command when you want virtualization and extra kernels:

```bash
./install.sh --yes --with-virt --with-kernels
```

For Android Studio, also include `--with-android`. Modern CSV is attempted through AUR by default unless `--skip-aur` is set.

### What gets installed

- **Desktop:** Hyprland, SDDM, Hyprlock, Waybar, SwayNC, Kitty, Firefox, Nautilus, Gedit, AbiWord, GNOME Disks, Wofi, and XDG user directories.
- **Media & system:** PipeWire, WirePlumber, NetworkManager, BlueZ, Tailscale, UFW (installed but not enabled), VLC, OBS Studio and screenshot/recording tools.
- **Development:** Neovim, Git, Node.js, npm, pnpm, Python, Rust via rustup, Go, Ruby, Java (OpenJDK), tmux and CLI tools.
- **Theme:** SDDM Astronaut theme, font packages and required Qt6 components.
- **Optional:** Android Studio, extra virtualization packages/kernels via flags.

The installer skips package names not available in configured pacman repositories, with a warning. It also bootstraps `yay` when AUR is enabled.

## Secrets

Secrets are **not stored in this public Git repository**. The installer creates `~/.config/secrets/env` with restricted permissions when missing.

```bash
nvim ~/.config/secrets/env
```

Example:

```bash
export WAKATIME_OAUTH_TOKEN="paste-your-own-token"
```

Keep `.config/secrets/` ignored in `~/.gitignore`. You generally do not need to reapply `chmod 600` after ordinary in-place edits; the installer enforces it during setup.

## SDDM theme

The chosen theme is `sddm-astronaut-theme`. The tracked backup is:

```text
~/.config/sddm-backup/
├── sddm.conf.d/theme.conf
└── themes/sddm-astronaut-theme/
```

The installer restores the theme and configuration to SDDM's system paths, falling back to the upstream theme if the backup isn't in the repository. Additional fonts and QML dependencies may vary by theme variant.

## Working with the bare repository

The repository metadata lives in `~/.dotfiles`; the working tree is `$HOME`.

Persist this alias in `~/.bashrc` (the installer also sets it up):

```bash
alias config='git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'
```

To track and push local changes:

```bash
config status
config add .config/hypr README.md
config diff --cached
config commit -m "Update dotfiles"
config push origin master
```

### Sync remote changes before pushing

Fetch first; this does **not** modify any working files:

```bash
config status
config fetch origin
config log --oneline --left-right HEAD...origin/master
```

If your working tree is clean and your local branch has no commits ahead of the remote, fast-forward:

```bash
config merge --ff-only origin/master
```

If local commits are ahead of remote, consider `config rebase origin/master` **after** backing up/stashing uncommitted changes. Fix conflicts manually if Git reports any. Avoid `reset --hard` and forced checkout on a machine with local configurations you want to keep.

For a README-only PR, branch from synced `master`:

```bash
config switch -c docs/update-readme
# edit README.md
config add README.md
config commit -m "Document installer"
config push -u origin docs/update-readme
```

Then open the PR on GitHub targeting `master`.

## Repository

https://github.com/tomleejumah/my-dot-files

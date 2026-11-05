#!/usr/bin/env bash
# Fresh Arch setup: packages, dotfiles (bare repo), SDDM astronaut theme, dev tooling.
# Usage: ./install.sh [--yes] [--skip-aur] [--with-android] [--with-virt] [--with-kernels] [--no-sddm] [--reflect]
set -Eeuo pipefail

REPO_SSH="git@github.com:tomleejumah/my-dot-files.git"
REPO_HTTPS="https://github.com/tomleejumah/my-dot-files.git"
THEME_UPSTREAM="https://github.com/Keyitdev/sddm-astronaut-theme.git"
DOTFILES="$HOME/.dotfiles"
BACKUP="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
LOG="$HOME/install-$(date +%Y%m%d-%H%M%S).log"

ASSUME_YES=0 SKIP_AUR=0 WITH_ANDROID=0 WITH_VIRT=0 WITH_KERNELS=0 NO_SDDM=0 REFLECT=0
for arg in "$@"; do
    case "$arg" in
        --yes)          ASSUME_YES=1 ;;
        --skip-aur)     SKIP_AUR=1 ;;
        --with-android) WITH_ANDROID=1 ;;
        --with-virt)    WITH_VIRT=1 ;;
        --with-kernels) WITH_KERNELS=1 ;;
        --no-sddm)      NO_SDDM=1 ;;
        --reflect)      REFLECT=1 ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

PACMAN_FLAGS=(--needed)
YAY_FLAGS=(--needed)
if (( ASSUME_YES )); then
    PACMAN_FLAGS+=(--noconfirm)
    YAY_FLAGS+=(--noconfirm)
fi

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mWARNING: %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

trap 'warn "Failed at line $LINENO: $BASH_COMMAND"' ERR

# --------------------------------------------------
# Preflight
# --------------------------------------------------

[[ -f /etc/arch-release ]] || die "Arch Linux only."
(( EUID != 0 )) || die "Do not run as root (makepkg refuses). Run as your user."
ping -c1 -W3 archlinux.org >/dev/null 2>&1 || die "No network. Connect first (nmcli / iwctl)."

sudo -v
# Keep sudo alive for the whole run
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
KEEPALIVE_PID=$!
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

exec > >(tee -a "$LOG") 2>&1
log "Logging to $LOG"

sudo timedatectl set-ntp true || warn "Could not enable NTP"

# --------------------------------------------------
# Mirrors (optional)
# --------------------------------------------------

if (( REFLECT )); then
    log "Refreshing mirrors"
    sudo pacman -S "${PACMAN_FLAGS[@]}" reflector
    sudo reflector --latest 20 --protocol https --sort rate \
        --save /etc/pacman.d/mirrorlist || warn "reflector failed"
fi

# --------------------------------------------------
# Packages
# --------------------------------------------------

log "Installing system packages"

PACKAGES=(
    # Essentials
    git openssh curl wget rsync base-devel unzip zip tar jq fzf ripgrep fd
    less which usbutils dmidecode pacman-contrib tmux fastfetch rclone
    exfat-utils

    # Hyprland
    hyprland hyprlock hypridle hyprpaper
    xdg-desktop-portal-hyprland hyprpolkitagent
    qt5-wayland qt6-wayland sway

    # Desktop
    waybar swaync mako kitty firefox wofi xdg-user-dirs sddm
    nautilus gvfs gvfs-mtp file-roller sushi loupe baobab
    gedit abiword gnome-disk-utility gnome-themes-extra
    vlc vlc-plugin-ass vlc-plugin-ffmpeg obs-studio

    # Theming
    nwg-look kvantum qt5ct qt6ct

    # SDDM astronaut theme deps
    qt6-svg qt6-virtualkeyboard qt6-multimedia

    # Network / Bluetooth / misc services
    networkmanager network-manager-applet bluez bluez-utils blueman
    rfkill libnotify tailscale ufw android-tools

    # Audio
    pipewire pipewire-alsa pipewire-pulse wireplumber playerctl pavucontrol

    # Hyprland utilities
    brightnessctl wlsunset wl-clipboard cliphist grim slurp wf-recorder

    # Development
    neovim nodejs npm pnpm python python-pip rustup go ruby jdk-openjdk tinyxxd

    # Fonts
    ttf-dejavu ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

    linux-firmware
)

# Optional groups
if (( WITH_VIRT )); then
    PACKAGES+=(qemu-desktop libvirt virt-manager edk2-ovmf dnsmasq swtpm spice-vdagent waydroid)
fi
if (( WITH_KERNELS )); then
    PACKAGES+=(linux-headers linux-lts linux-lts-headers linux-zen linux-zen-headers
               dkms v4l2loopback-dkms v4l2loopback-utils)
fi

# CPU microcode (no GPU drivers on purpose)
if grep -q GenuineIntel /proc/cpuinfo; then PACKAGES+=(intel-ucode)
elif grep -q AuthenticAMD /proc/cpuinfo; then PACKAGES+=(amd-ucode)
fi

sudo pacman -Syu "${PACMAN_FLAGS[@]}" git base-devel   # sync + upgrade first

# Drop packages that don't exist so one typo can't abort the transaction
AVAILABLE=()
for p in "${PACKAGES[@]}"; do
    if pacman -Si "$p" >/dev/null 2>&1; then
        AVAILABLE+=("$p")
    else
        warn "Not in repos, skipping: $p"
    fi
done
sudo pacman -S "${PACMAN_FLAGS[@]}" "${AVAILABLE[@]}"

# --------------------------------------------------
# Services
# --------------------------------------------------

log "Enabling services"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth || warn "Bluetooth unavailable"
sudo systemctl enable --now tailscaled || warn "tailscaled unavailable"
# ufw is installed but NOT enabled (avoid locking yourself out): sudo ufw allow ssh && sudo ufw enable

if (( WITH_VIRT )); then
    sudo systemctl enable --now libvirtd.socket || warn "libvirtd unavailable"
    sudo usermod -aG libvirt,kvm "$USER"
fi
if (( WITH_KERNELS )) && [[ -f /boot/grub/grub.cfg ]]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "grub-mkconfig failed"
fi
if (( ! NO_SDDM )); then
    sudo systemctl enable sddm
fi

# --------------------------------------------------
# yay + AUR
# --------------------------------------------------

if (( ! SKIP_AUR )); then
    if ! command -v yay >/dev/null 2>&1; then
        log "Bootstrapping yay"
        tmp="$(mktemp -d)"
        git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
        ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
        rm -rf "$tmp"
    fi
fi

# --------------------------------------------------
# Dotfiles (bare repo)
# --------------------------------------------------

log "Setting up dotfiles"

config() { git --git-dir="$DOTFILES" --work-tree="$HOME" "$@"; }

if [[ ! -d "$DOTFILES" ]]; then
    # Pick SSH if a key already works, otherwise HTTPS
    ssh_out="$(ssh -T -o BatchMode=yes -o ConnectTimeout=8 \
        -o StrictHostKeyChecking=accept-new git@github.com 2>&1 || true)"
    if [[ "$ssh_out" == *"successfully authenticated"* ]]; then
        git clone --bare "$REPO_SSH" "$DOTFILES"
    else
        warn "No working GitHub SSH key; cloning over HTTPS."
        git clone --bare "$REPO_HTTPS" "$DOTFILES"
        config remote set-url origin "$REPO_SSH"   # switch back once you add a key
    fi

    config config --local status.showUntrackedFiles no

    log "Backing up conflicting files to $BACKUP"
    mkdir -p "$BACKUP"
    backed_up=0
    while IFS= read -r -d '' file; do
        target="$HOME/$file"
        if [[ -e "$target" || -L "$target" ]]; then
            mkdir -p "$BACKUP/$(dirname "$file")"
            mv "$target" "$BACKUP/$file"
            backed_up=1
        fi
    done < <(config ls-tree -r -z --name-only HEAD)

    config checkout -f
    (( backed_up )) && echo "Backup saved: $BACKUP" || rmdir "$BACKUP"
else
    config config --local status.showUntrackedFiles no
    warn "Dotfiles repo already exists; checkout skipped. Run: config status"
fi

# --------------------------------------------------
# Shell: alias + secrets (after checkout so .bashrc isn't clobbered)
# --------------------------------------------------

log "Configuring shell"
touch "$HOME/.bashrc"

if ! grep -Fq 'alias config=' "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Bare Git dotfiles repository
alias config='git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'
EOF
fi

SECRETS_DIR="$HOME/.config/secrets"
SECRETS_FILE="$SECRETS_DIR/env"
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"
if [[ ! -e "$SECRETS_FILE" ]]; then
    ( umask 077
      cat > "$SECRETS_FILE" <<'EOF'
#!/usr/bin/env bash
# Add your environment variables manually.
# export WAKATIME_OAUTH_TOKEN="..."
EOF
    )
fi
chmod 600 "$SECRETS_FILE"

if ! grep -Fq '.config/secrets/env' "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Load private environment variables
if [[ -f "$HOME/.config/secrets/env" ]]; then
    source "$HOME/.config/secrets/env"
fi
EOF
fi

# --------------------------------------------------
# SDDM astronaut theme
# Prefers your tracked copy; falls back to upstream (Keyitdev)
# --------------------------------------------------

if (( ! NO_SDDM )); then
    log "Installing SDDM astronaut theme"

    SDDM_BACKUP="$HOME/.config/sddm-backup"
    THEME_NAME="sddm-astronaut-theme"
    THEME_DST="/usr/share/sddm/themes/$THEME_NAME"

    sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d

    if [[ -d "$SDDM_BACKUP/themes/$THEME_NAME" ]]; then
        sudo rm -rf "$THEME_DST"
        sudo cp -a "$SDDM_BACKUP/themes/$THEME_NAME" /usr/share/sddm/themes/
    else
        warn "Tracked theme not found; cloning upstream."
        tmp="$(mktemp -d)"
        git clone -b master --depth 1 "$THEME_UPSTREAM" "$tmp/theme"
        sudo rm -rf "$THEME_DST"
        sudo cp -a "$tmp/theme" "$THEME_DST"
        sudo rm -rf "$THEME_DST/.git"
        rm -rf "$tmp"
    fi

    # Theme fonts
    if [[ -d "$THEME_DST/Fonts" ]]; then
        sudo cp -r "$THEME_DST"/Fonts/* /usr/share/fonts/
        sudo fc-cache -f >/dev/null
    fi

    # SDDM config
    if [[ -f "$SDDM_BACKUP/sddm.conf.d/theme.conf" ]]; then
        sudo cp -a "$SDDM_BACKUP/sddm.conf.d/theme.conf" /etc/sddm.conf.d/
    else
        sudo tee /etc/sddm.conf.d/theme.conf >/dev/null <<EOF
[Theme]
Current=$THEME_NAME

[General]
InputMethod=qtvirtualkeyboard
EOF
    fi
fi

# --------------------------------------------------
# User directories
# --------------------------------------------------

log "Creating user directories"
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Videos/Screencasts"

# --------------------------------------------------
# Optional AUR apps
# --------------------------------------------------

if (( ! SKIP_AUR )); then
    log "Installing AUR packages"
    AUR=(modern-csv-bin)
    (( WITH_ANDROID )) && AUR+=(android-studio)

    for p in "${AUR[@]}"; do
        if yay -Si "$p" >/dev/null 2>&1; then
            yay -S "${YAY_FLAGS[@]}" "$p" || warn "AUR install failed: $p"
        else
            warn "Not found in AUR: $p"
        fi
    done
else
    warn "Skipping AUR packages (--skip-aur)."
fi

# --------------------------------------------------
# Rust
# --------------------------------------------------

log "Setting up Rust"
rustup default stable || warn "Rust setup failed"

# --------------------------------------------------
# tmux (TPM) and Neovim plugins
# --------------------------------------------------

log "Setting up tmux plugins"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" \
        || warn "TPM clone failed"
fi
if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "TPM plugin install failed"
fi

log "Syncing Neovim plugins"
if [[ -d "$HOME/.config/nvim" ]]; then
    timeout 300 nvim --headless "+Lazy! sync" +qa 2>&1 \
        || warn "Neovim plugin sync failed or timed out; open nvim and run :Lazy sync"
fi

# --------------------------------------------------
# Permissions
# --------------------------------------------------

log "Fixing script permissions"
for d in "$HOME/.config/waybar/scripts" "$HOME/.config/hypr/scripts" "$HOME/.local/bin"; do
    [[ -d "$d" ]] && find "$d" -type f \( -name '*.sh' -o -perm -u+x \) -exec chmod +x {} +
done

# --------------------------------------------------
# Done
# --------------------------------------------------

log "Installation complete"
cat <<EOF

Dotfiles: $DOTFILES
Secrets:  $SECRETS_FILE
Log:      $LOG

Next steps:
 1. Add API tokens to ~/.config/secrets/env
 2. If cloned over HTTPS: generate an SSH key (ssh-keygen -t ed25519), add it to GitHub
 3. Reboot (kernel/microcode/SDDM): sudo reboot
EOF

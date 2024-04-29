#/bin/sh

#script caught of the Github Liquorix-Package Repository and modified for my use

set -euo pipefail

log() {
    local level=$1
    local message=$2

    echo ""
    case "$level" in
    INFO) printf "\033[32m[INFO ] %s\033[0m\n" "$message" ;;  # green
    WARN) printf "\033[33m[WARN ] %s\033[0m\n" "$message" ;;  # yellow
    ERROR) printf "\033[31m[ERROR] %s\033[0m\n" "$message" ;; # red
    *) printf "[UNKNOWN] %s\n" "$message" ;;
    esac
    echo ""
}

if [ "$(id -u)" -ne 0 ]; then
    log ERROR "You must run this script as root!"
    exit 1
fi

if [ "$(uname -m)" != x86_64 ]; then
    log ERROR "Architecture not supported"
    exit 1
fi

export NEEDRESTART_SUSPEND="*" # suspend needrestart or it will restart services automatically

# Smash all possible distributions into one line
dists="$(
    grep -P '^ID.*=' /etc/os-release | cut -f2 -d= | tr '\n' ' ' |
        tr '[:upper:]' '[:lower:]' | tr -dc '[:lower:] [:space:]'
)"

# Append upstream distributions through package manager landmarks
command -v apt-get &>/dev/null && dists="$dists debian"
command -v pacman &>/dev/null && dists="$dists arch"

# Deduplicate and trim list of discovered distributions
dists=$(echo "$dists" | tr '[:space:]' '\n' | sort | uniq | xargs)

log INFO "Possible distributions: $dists"

case "$dists" in
*arch*)

    repo_file='/etc/pacman.conf'
    gpg_key1='9AE4078033F8024D'
    gpg_key='3056513887B78AEB'
    chk='https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    chm='https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

    # Fist step
    sudo pacman-key --keyserver hkps://keyserver.ubuntu.com --recv-keys $gpg_key1
    sudo pacman-key --lsign-key $gpg_key1
    log INFO "Liquorix keyring added to pacman-key"

    if ! grep -q 'liquorix.net/archlinux' $repo_file; then
        echo -e '\n[liquorix]\nServer = https://liquorix.net/archlinux/$repo/$arch' |
            sudo tee -a $repo_file
        log INFO "Liquorix repository added successfully to $repo_file"
    else
        log INFO "Liquorix repo already configured in $repo_file, skipped add step"
    fi

    if ! pacman -Q linux-lqx | awk '{print $1}' >/dev/null; then
        sudo pacman -Sy --noconfirm linux-lqx linux-lqx-headers
        log INFO "Liquorix kernel installed successfully"
    else
        log INFO "Liquorix kernel already installed"
    fi

    grub_cfg='/boot/grub/grub.cfg'
    if [ -f "$grub_cfg" ]; then
        if sudo grub-mkconfig -o "$grub_cfg"; then
            log INFO "GRUB updated successfully"
        else
            log ERROR "GRUB update failed"
        fi
    fi

    # Second step (Note: Chaotic-AUR is being added later to avoid the liquorix kernel update issue)
    sudo pacman-key --keyserver hkps://keyserver.ubuntu.com --recv-keys $gpg_key
    sudo pacman-key --lsign-key $gpg_key
    log INFO "Chaotic-AUR keyring added to pacman-key"

    if ! grep -q '/etc/pacman.d/chaotic-mirrorlist' $repo_file; then
        echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' |
            sudo tee -a $repo_file
        log INFO "Chaotic-AUR repository added successfully to $repo_file"
    else
        log INFO "Chaotic-AUR repo already configured in $repo_file, skipped add step"
    fi

    if ! pacman -Q chaotic-keyring | awk '{print $1}' >/dev/null; then
        sudo pacman -U --noconfirm $chk
        log INFO "Chaotic-keyring installed successfully"
    else
        log INFO "Chaotic-keyring already installed"
    fi

    if ! pacman -Q chaotic-mirrorlist | awk '{print $1}' >/dev/null; then
        sudo pacman -U --noconfirm $chm
        log INFO "Chaotic-mirrorlist installed successfully"
    else
        log INFO "Chaotic-mirrorlist already installed"
    fi

    # Step Three
    if ! grep -q 'nihaals.github.io/visual-studio-code-insiders-arch/' $repo_file; then
        echo -e '\n[visual-studio-code-insiders]\nServer = https://nihaals.github.io/visual-studio-code-insiders-arch/\nSigLevel = PackageOptional' |
            sudo tee -a $repo_file
        log INFO "Visual-studio-code-insiders repository added successfully to $repo_file"
    else
        log INFO "Visual-studio-code-insiders repo already configured in $repo_file, skipped add step"
    fi

    if ! pacman -Q visual-studio-code-insiders | awk '{print $1}' >/dev/null; then
        sudo pacman -Sy --noconfirm visual-studio-code-insiders
        log INFO "Visual-studio-code-insiders installed successfully"
    else
        log INFO "Visual-studio-code-insiders already installed"
    fi

    # Installs the noise-suppression-for-voice package ladspa and pipewire-pulse

    if ! pacman -Q noise-suppression-for-voice | awk '{print $1}' >/dev/null; then
        sudo pacman -Sy --noconfirm noise-suppression-for-voice ladspa
        log INFO "Noise-suppression-for-voice installed successfully"
    else
        log INFO "Noise-suppression-for-voice already installed"
    fi

    if ! pacman -Q pipewire-pulse | awk '{print $1}' >/dev/null; then
        sudo pacman -Sy --noconfirm pipewire-pulse
        log INFO "Pipewire-pulse installed successfully"
    else
        log INFO "Pipewire-pulse already installed"
    fi

    # Create the folder and pick up the repository files and activates the services

    if [ ! -d ~/.config/pipewire/ ]; then
        mkdir -p ~/.config/pipewire/
        else
        log INFO "Pipewire folder already exists"
    fi

    if [ ! -d ~/.config/systemd/user/ ]; then
        mkdir -p ~/.config/systemd/user/
        else
        log INFO "Systemd user folder already exists"
    fi

    if [ ! -d ~/.config/pipewire/input-filter-chain.conf ]; then
        wget https://raw.githubusercontent.com/viniciusred/MyWorkstation/main/noise-suppression/input-filter-chain.conf -O ~/.config/pipewire/input-filter-chain.conf
        else
        log INFO "Pipewire input-filter-chain.conf already exists"
    fi

    if [ ! -d ~/.config/systemd/user/pipewire-input-filter-chain.service ]; then
        wget https://raw.githubusercontent.com/viniciusred/MyWorkstation/main/noise-suppression/pipewire-input-filter-chain.service -O ~/.config/systemd/user/pipewire-input-filter-chain.service
        else
        log INFO "pipewire-input-filter-chain.service already exists"
    fi

    if ! systemctl --user is-active pipewire-input-filter-chain.service &>/dev/null; then
        LOG INFO "Reloading systemd"
        sudo systemctl --user daemon-reload

        if ! systemctl --user is-enabled pipewire-input-filter-chain.service &>/dev/null; then
            sudo systemctl --user enable --now pipewire-input-filter-chain.service
            log INFO "Noise-suppresion-for-voice service enabled"
        fi
    fi

    # Install docker and active the service
    
    if ! pacman -Q docker | awk '{print $1}' >/dev/null; then
        sudo pacman -Sy --noconfirm docker docker-buildx
        log INFO "Docker installed successfully"
    if ! systemctl is-active docker.service &>/dev/null; then
        sudo systemctl enable --now docker.service
        log INFO "Docker service enabled"
    fi
        sudo usermod -aG docker $USER && newgrp docker
        log INFO "User added to docker group"
    else
        log INFO "Docker already installed"
    fi

    ;;
*)
    log ERROR "This distribution is not supported at this time"
    exit 1
    ;;
esac

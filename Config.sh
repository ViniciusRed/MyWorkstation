echo "[Attention sudo command being used]"
sudo pacman --noconfirm -Sy && sudo pacman --noconfirm -Syy && sudo pacman --asdeps  --needed --noconfirm -S file-roller unrar
timedatectl
timedatectl set-local-rtc 0 #off to sync time
timedatectl set-timezone America/Sao_Paulo
sudo timedatectl set-ntp true
timedatectl set-local-rtc 1
cd && cd
git clone https://aur.archlinux.org/yay.git && cd yay
makepkg -si
yay -S pamac-aur
cd && cd
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
sudo auto-cpufreq --install
clear
echo "[Please restart Arch Linux]"

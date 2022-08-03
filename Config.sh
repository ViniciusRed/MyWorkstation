sudo pacman -Sy
timedatectl
timedatectl set-local-rtc 0 #off to sync time
timedatectl set-timezone America/Sao_Paulo
sudo timedatectl set-ntp true
timedatectl set-local-rtc 1
git clone https://aur.archlinux.org/yay.git && cd yay
makepkg -si
#test vscode
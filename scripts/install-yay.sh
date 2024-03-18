# Basic Install Script
yay_repo="$HOME/yay/repo"
mkdir -p "$yay_repo"
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git "$yay_repo"
(cd "$yay_repo" && makepkg -si)

# Configure -dev packages
yay -Y --gendb
yay -Y --devel --save

function os_setup_git()
{
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status
  git config --global user.name "Ludwig Fiolka"
  git config --global user.email urushiraa@gmail.com
}

function os_setup_yay()
{
  wget "https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz"
  tar xvzf yay.tar.gz
  cd yay
  sudo pacman -Syy
  sudo pacman -S make gcc binutils fakeroot
  makepkg -s
  sudo pacman -U yay*
  cd ..
  rm -fr yay*
}

function os_setup_xfce()
{
  yay -S arc-gtk-theme paper-icon-theme-git
}

function os_setup_qtc()
{
  yay -S qtcreator qt5ct
  mkdir -p ${HOME}/.config
  cd ${HOME}/.config/
  tar xvzf ${HOME}/.bashrc.d/res/os_setup_qtc.tar.gz
}

function _os_setup_topic_git()
{
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status
  git config --global user.name "Ludwig Fiolka"
  git config --global user.email urushiraa@gmail.com
}

function _os_setup_topic_yay()
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

function _os_setup_topic_xfce()
{
  yay -S arc-gtk-theme paper-icon-theme-git nord-xfce-terminal tempus-themes-xfce4-terminal-git xfce4-terminal-base16-colors-git
}

function _os_setup_topic_qtc()
{
  yay -S qtcreator qt5ct
  mkdir -p ${HOME}/.config
  cd ${HOME}/.config/
  tar xvzf ${HOME}/.bashrc.d/res/os_setup_qtc.tar.gz
}

function _os_setup_topic_laserweb()
{
  wget https://github.com/LaserWeb/LaserWeb4-Binaries/releases/download/untagged-4818330b6baa8213d4a7/laserweb-builder-v4.0.996-130-x86_64.AppImage
  sudo mv laserweb-builder-v4.0.996-130-x86_64.AppImage /opt/laserweb4
  sudo chmod a+x /opt/laserweb4
}

_os_setup()
{
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(declare -F | awk '{print $3}' | grep '^_os_setup_topic_' | cut -f 5- -d '_')"

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _os_setup os_setup

function os_setup()
{
  local topics=($(declare -F | awk '{print $3}' | grep '^_os_setup_topic_' | cut -f 5- -d '_'))

  if [[ "${1}" == "" ]]; then
    echo 'usage os_setup <topic>'
    echo " tun the setup for an available topic: ${topics[@]}"
    return 1
  fi

  _os_setup_topic_${1}
}

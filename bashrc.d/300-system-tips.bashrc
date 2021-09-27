function _os_tips_topic_pwmconfig()
{
  echo '== basic setup =='
  echo 'see: https://wiki.archlinux.org/title/fan_speed_control'
  echo 'basically, you need to install the lm_sensors package, then run sensors-detect & pwmconfig'
  echo 'the fancontrol-gui package provides with a gui to configure the fancontrol daemon.'
  echo ''
  echo '== no fans detected by pwmconfig or sensors =='
  echo 'in order for pwmconfig (& fancontrol) to detect pwm controls on an Asus motherboard (and probably other hardware too)'
  echo ' you need to allow the kernel to grand lm-sensors access to the pwm chip installed on the board.'
  echo 'this is done by editing /etc/default/grub to append the following option to GRUB_CMDLINE_LINUX:'
  echo 'GRUB_CMDLINE_LINUX="... acpi_enforce_resources=lax"'
  echo 'then, simply run update-grub & reboot. your fans should now appear when running the sensors command and you will be able to setup pwmconfig'
  echo 'source: https://askubuntu.com/questions/1145968/how-to-see-all-my-fans-in-sensors'
}

function _os_tips_topic_xps13()
{
  echo '== howdy =='
  echo 'install the howdy package from AUR'
  echo 'for howdy to work with infrared camera, edit /lib/security/howdy/config.ini and set device_path = /dev/video2 (/dev/video2 points to the infrared camera)'
  echo 'ensure the following are set to avoid storing snapshots locally:'
  echo '[snapshots]'
  echo 'capture_failed = false'
  echo 'capture_successful = false'
}

_os_tips()
{
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(declare -F | awk '{print $3}' | grep '^_os_tips_topic_' | cut -f 5- -d '_')"

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _os_tips os_tips

function os_tips()
{
  local topics=($(declare -F | awk '{print $3}' | grep '^_os_tips_topic_' | cut -f 5- -d '_'))

  if [[ "${1}" == "" ]]; then
    echo 'usage os_tips <topic>'
    echo " prints out tips about a given topic. available topics are: ${topics[@]}"
    return 1
  fi

  _os_tips_topic_${1}
}

# ==========================================================================
# Add nice colors and command exec time into bash
# ==========================================================================
[ -e "/etc/DIR_COLORS" ] && DIR_COLORS="/etc/DIR_COLORS"
[ -e "$HOME/.dircolors" ] && DIR_COLORS="$HOME/.dircolors"
[ -e "$DIR_COLORS" ] || DIR_COLORS=""
eval "`dircolors -b $DIR_COLORS`"

export PROMPT_COMMAND=__prompt_command

__prompt_command() {
    local _last_exit_code="$?" # This needs to be first
    timer_stop # stop timer

    PS1="\[\e[2m\]+${timer_show}\[\e[0m\] "
    PS1+='[\[\e[36m\]\u\[\e[0m\]@\[\e[37m\]\h\[\e[37m\]\[\e[2m\] \W\[\e[0m\]'
    if [[ -d ".git" ]]; then
      local _br="$(git rev-parse --abbrev-ref HEAD)"
      if [[ "${_br}" == "main" || "${_br}" == "master" ]]; then
        PS1+="(\[\e[35m\]${_br}\[\e[0m\])"
      else
        PS1+="(\[\e[36m\]${_br}\[\e[0m\])"
      fi
    fi
    PS1+="]"

    if [[ -d ".git" ]]; then
      local _mod=$(git ls-files -m | wc -l)
      local _del=$(git ls-files -d | wc -l)
      local _oth=$(git ls-files -o | wc -l)
      local _stg=$(git diff --name-only --cached | wc -l)
      local _unp=$(git log --branches --not --remotes --oneline | wc -l)

      PS1+="\[\e[35m\]"
      if (( _mod > 0 )); then
        PS1+=" ❱${_mod}"
      fi
      if (( _del > 0 )); then
        PS1+=" ✖${_del}"
      fi
      if (( _oth > 0 )); then
        PS1+=" •${_oth}"
      fi
      if (( _stg > 0 )); then
        PS1+=" ⬓${_stg}"
      fi
      if (( _unp > 0 )); then
        PS1+=" ⇪${_unp}"
      fi

      PS1+="\[\e[0m\] "
    fi

    if [[ "${_last_exit_code}" != "0" ]]; then
      PS1="${PS1}\[\e[31m\]\$\[\e[0m\] "
    else
      PS1="${PS1}\[\e[32m\]\$\[\e[0m\] "
    fi

    echo -en "\033]0;${USER}@${HOSTNAME} $(pwd)'\007"
}

# Ensure window size is checked for word wrapping
if [[ "$(get_shell 2> /dev/null)" = "bash" ]]; then
  shopt -s checkwinsize
fi

# see https://stackoverflow.com/questions/1862510/how-can-the-last-commands-wall-time-be-put-in-the-bash-prompt
function timer_now {
    date +%s%N
}

function timer_start {
    timer_start=${timer_start:-$(timer_now)}
}

function timer_stop {
    local delta_us=$((($(timer_now) - $timer_start) / 1000))
    local us=$((delta_us % 1000))
    local ms=$(((delta_us / 1000) % 1000))
    local s=$(((delta_us / 1000000) % 60))
    local m=$(((delta_us / 60000000) % 60))
    local h=$((delta_us / 3600000000))
    # Goal: always show around 3 digits of accuracy
    if ((h > 0)); then timer_show=${h}h${m}m
    elif ((m > 0)); then timer_show=${m}m${s}s
    elif ((s >= 10)); then timer_show=${s}.$((ms / 100))s
    elif ((s > 0)); then timer_show=${s}.$(printf %03d $ms)s
    elif ((ms >= 100)); then timer_show=${ms}ms
    elif ((ms > 0)); then timer_show=${ms}.$((us / 100))ms
    else timer_show=${us}us
    fi
    unset timer_start
}
trap 'timer_start' DEBUG

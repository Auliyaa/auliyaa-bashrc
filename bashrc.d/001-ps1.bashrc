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

    PS1="[${col_l_blue}\u${col_rst}@${col_l_blue}\h${col_rst} ${col_l_grey}\W${col_rst}"

    if [[ -d ".git" ]]; then
      local _br="$(git rev-parse --abbrev-ref HEAD)"
      if [[ "${_br}" == "main" || "${_br}" == "master" ]]; then
        PS1+="(${col_l_purple}${_br}${col_rst})"
      else
        PS1+="(${col_l_blue}${_br}${col_rst})"
      fi
    fi
    PS1+="]"

    if [[ -d ".git" ]]; then
      local _mod=$(git ls-files -m | wc -l)
      local _del=$(git ls-files -d | wc -l)
      local _oth=$(git ls-files -o | wc -l)
      local _stg=$(git diff --name-only --cached | wc -l)
      local _unp=$(git log --branches --not --remotes --oneline | wc -l)

      PS1+="${col_l_purple}"
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

      PS1+="${col_rst} "
    fi

    if [[ "${_last_exit_code}" != "0" ]]; then
      PS1="${PS1}${col_l_red}\$${col_rst} "
    else
      PS1="${PS1}${col_l_green}\$${col_rst} "
    fi

    echo -en "\033]0;${USER}@${HOSTNAME} $(pwd)'\007"
}

# Ensure window size is checked for word wrapping
if [[ "$(get_shell 2> /dev/null)" = "bash" ]]; then
  shopt -s checkwinsize
fi

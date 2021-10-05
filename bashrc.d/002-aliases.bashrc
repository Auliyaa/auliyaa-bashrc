# ==========================================================================
# add colored output to common commands
# ==========================================================================
alias ls='ls --color=auto'
alias l='ls --color=auto'
alias ll='ls -ltrh --color=auto'
alias la='ls -latrh --color=auto'
alias grep='grep --colour=auto'
alias less='less -r'

# ==========================================================================
# Display result of wget in the console
# ==========================================================================
alias cwget='wget -q -O - "$@"'

#===================================
# Display PID of a process by name
#===================================
function ppid()
{
  ps aux | grep "$@" | grep -v grep | awk '{ print $2 }'
}

# ==========================================================================
# Remove colored output from a command
# ==========================================================================
function remove_colors()
{
  sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"
}

# ==========================================================================
# /opt software
# ==========================================================================
alias vooya='/opt/vooya'
alias cura='/opt/cura'
alias laserweb4='/opt/laserweb4'

# encrypt a string given as parameter
function encrypt()
{
  openssl aes-256-cbc -a -pbkdf2
}

# decrypt a string given as parameter
function decrypt()
{
  openssl aes-256-cbc -d -a -pbkdf2
}

#===================================
# decrypt a key from the ~/keys folder
#===================================
_deckey()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(ls ${HOME}/.bashrc.d/keys)"

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _deckey deckey
complete -F _deckey pkey

function deckey()
{
  cat "${HOME}/.bashrc.d/keys/${1}" | decrypt | xclip -selection c
  echo "copied to clipboard"
}

function pkey()
{
  cat "${HOME}/.bashrc.d/keys/${1}" | decrypt
}

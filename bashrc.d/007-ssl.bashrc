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
_key_comp()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(find ${HOME}/.bashrc.d/keys/ -type f | cut -f 6- -d '/')"

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _key_comp key_print
complete -F _key_comp key_copy
complete -F _key_comp key_update
complete -F _key_comp key_rm

function key_print()
{
  cat "${HOME}/.bashrc.d/keys/${1}" | decrypt
}

function key_copy()
{
  key_print "${1}" | xclip -selection c
  echo "copied to clipboard"
}

function key_update()
{
  local kpath="${HOME}/.bashrc.d/keys/${1}"
  local kval="${2}"
  mkdir -p "$(dirname "${kpath}")"
  echo "${kval}" | encrypt > ${kpath}
}

function key_rm()
{
  rm -f "${HOME}/.bashrc.d/keys/${1}"
}

function key_ls()
{
  find ${HOME}/.bashrc.d/keys/ -type f | cut -f 6- -d '/'
}

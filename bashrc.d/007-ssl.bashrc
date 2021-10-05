#===================================
# encrypt a string given as parameter
#===================================
function encrypt()
{
  openssl aes-256-cbc -a -pbkdf2
}

#===================================
# decrypt a string given as parameter
#===================================
function decrypt()
{
  openssl aes-256-cbc -d -a -pbkdf2
}

#===================================
# encrypt a file
#===================================
function encrypt_file()
{
  src="${1}"
  tgt="${2}"

  if [[ "${src}" == "" ]]; then
    echo 'usage: encrypt_file <src> [tgt]'
    echo ' src: source file'
    echo ' tgt: target file (defaults to <src>.enc)'
    return
  fi

  if [[ "${tgt}" == "" ]]; then
    tgt="${src}.enc"
  fi

  openssl aes-256-cbc -a -pbkdf2 -in "${src}" -out "${tgt}"
}

#===================================
# decrypt a file
#===================================
function decrypt_file()
{
  src="${1}"
  tgt="${2}"

  if [[ "${src}" == "" ]]; then
    echo 'usage: decrypt_file <src> [tgt]'
    echo ' src: source file'
    echo ' tgt: target file (defaults to <src>.dec)'
    return
  fi

  if [[ "${tgt}" == "" ]]; then
    tgt="${src}.dec"
  fi

  openssl aes-256-cbc -a -d -pbkdf2 -in "${src}" -out "${tgt}"
}

#===================================
# autocomplete
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

#===================================
# decrypt a key & print it
#===================================
function key_print()
{
  cat "${HOME}/.bashrc.d/keys/${1}" | decrypt
}

#===================================
# decrypt a key & copy to clipboard
#===================================
function key_copy()
{
  key_print "${1}" | xclip -selection c
  echo "copied to clipboard"
}

#===================================
# refresh a key
#===================================
function key_update()
{
  local kpath="${HOME}/.bashrc.d/keys/${1}"
  local kval="${2}"
  mkdir -p "$(dirname "${kpath}")"
  echo "${kval}" | encrypt > ${kpath}
}

#===================================
# delete a key
#===================================
function key_rm()
{
  rm -f "${HOME}/.bashrc.d/keys/${1}"
}

#===================================
# list keys
#===================================
function key_ls()
{
  find ${HOME}/.bashrc.d/keys/ -type f | cut -f 6- -d '/'
}

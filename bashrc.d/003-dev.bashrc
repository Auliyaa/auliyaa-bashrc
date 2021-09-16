export DEV_ROOT="${HOME}/dev"

_dev()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(ls ${DEV_ROOT})"

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

function dev()
{
  cd ${DEV_ROOT}/${1}
}

complete -F _dev dev

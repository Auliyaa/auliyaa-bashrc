export DEV_ROOT="${HOME}/dev"

#===================================
# quick cd to a dev project with autocomplete
#===================================
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

#===================================
# list of all dev projects currently on git
#===================================
function dev_ls()
{
  for f in ${DEV_ROOT}/*; do
    [ -d "${f}/.git" ] || continue;
    echo -n "$(basename "${f}")"
  done
  echo
}

#===================================
# quick status of all dev projects
#===================================
function dev_st()
{
  for proj in $(dev_ls); do
    pushd ${DEV_ROOT}/${proj} >/dev/null 2>&1
    local modif_str=""
    if [ "$(git diff origin/$(git_branch_name) --raw)" != "" ]; then
      local modif_str="${fmt_bold}${col_red} (*)${col_rst}"
    fi
    echo -e "${col_l_white}${proj}${col_rst} is on ${col_l_green}$(git_branch_name)${col_rst}${modif_str}"
    popd >/dev/null 2>&1
  done
}

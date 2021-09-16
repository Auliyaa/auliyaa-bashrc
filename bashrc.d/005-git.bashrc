_git_bin="$(which git)"

# print current branch name from current folder
function git_branch_name()
{
  git rev-parse --abbrev-ref HEAD
}

function git()
{
  if [[ "${1}" == "commit" && "${2}" == "-m" && "${3}" != "" ]]; then
    shift
    shift
    # prepend branch name to all commit messages
    local _msg="($(git_branch_name)) ${@}"
    ${_git_bin} commit -m "${_msg}"
    return 0
  fi

  ${_git_bin} "${@}"
}

_git_bin="$(which git)"

# ==========================================================================
# print current branch name from current folder
# ==========================================================================
function git_branch_name()
{
  git rev-parse --abbrev-ref HEAD
}

# ==========================================================================
# helpers for builtin functions
# ==========================================================================
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

# ==========================================================================
# GIT: List all branches merged on a specific branch
# ==========================================================================
function git_list_merged()
{
  tgt=$1
  for b in $(git branch -r --merged ${1}); do
    echo "${b}: $(git log --pretty='%H - %an (%ad): %s' ${b} | head -n1)"
  done
}


# ==========================================================================
# GIT: List all branches not merged on a specific branch
# ==========================================================================
function git_list_unmerged()
{
  tgt=$1
  for b in $(git branch -r --no-merged ${1}); do
    echo "${b}: $(git log --pretty='%H - %an (%ad): %s' ${b} | head -n1)"
  done
}

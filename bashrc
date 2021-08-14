# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# subscripts
for f in ~/.bashrc.d/*.bashrc; do
  source "${f}"
done

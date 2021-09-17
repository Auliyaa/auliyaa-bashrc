#===================================
# systemctl alias
#===================================
function sctl()
{
  # Some commands aliases
  local cmd="${1}"
  shift
  local services=(${@})

  [[ "${cmd}" == "st" ]] && cmd="status"
  [[ "${cmd}" == "dr" ]] && cmd="daemon-reload"

  if [[ "${cmd}" == "daemon-reload" ]]; then
    sudo systemctl daemon-reload
    return
  fi

  if [[ "${#services[@]}" == "0" ]]; then
    services=(${_SCTL_LAST})
  fi

  for service in "${services[@]}"; do
    echo -e "${FORMAT_DIM}sudo systemctl${FORMAT_RST} ${cmd} ${FORMAT_BOLD}${service}${FORMAT_RST}"
    sudo systemctl ${cmd} ${service}
    export _SCTL_LAST="${service}"
  done
}

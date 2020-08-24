#!/bin/bash -e
ENABLE_DYNATRACE="${ENABLE_DYNATRACE:-false}"
DT_TENANT="$DT_TENANT"
DT_API_TOKEN="$DT_API_TOKEN"
DT_ONEAGENT_FOR="${DT_ONEAGENT_FOR:-all}"
DT_ONEAGENT_BITNESS="64"
DT_ONEAGENT_PREFIX_DIR="/tmp"
DT_ONEAGENT_INSTALL_DIR="$DT_ONEAGENT_PREFIX_DIR/dynatrace/oneagent"

inject_dynatrace_oneagent() {
  if [ "$ENABLE_DYNATRACE" = "true" ]; then
    if is_dynatrace_oneagent_installed; then
      if [ "$DT_ONEAGENT_FOR" != "nodejs" ]; then
        export EXEC_CMD_PREFIX="$DT_ONEAGENT_INSTALL_DIR/dynatrace-agent$DT_ONEAGENT_BITNESS.sh"
      fi
    fi
  fi
}

install_dynatrace_oneagent() {
  echo "---> Installing Dynatrace OneAgent..."
  local ONEAGENT_INSTALL_SH_URL="https://raw.githubusercontent.com/dynatrace-innovationlab/oneagent-paas-install/master/dynatrace-oneagent-paas.sh"
  local ONEAGENT_INSTALL_SH_FILE=`basename "$ONEAGENT_INSTALL_SH_URL"`

  curl -sSL -o "$ONEAGENT_INSTALL_SH_FILE" "$ONEAGENT_INSTALL_SH_URL"
  DT_TENANT="$DT_TENANT" DT_API_TOKEN="$DT_API_TOKEN" DT_ONEAGENT_BITNESS="$DT_ONEAGENT_BITNESS" DT_ONEAGENT_FOR="$DT_ONEAGENT_FOR" DT_ONEAGENT_PREFIX_DIR="$DT_ONEAGENT_PREFIX_DIR" sh "$ONEAGENT_INSTALL_SH_FILE"
  rm -f "$ONEAGENT_INSTALL_SH_FILE"
}

is_dynatrace_oneagent_installed() {
  [ -d "$DT_ONEAGENT_INSTALL_DIR" ]
}

should_install_dynatrace_oneagent() {
  if [ "$ENABLE_DYNATRACE" != "true" ]; then
    return 1
  fi
  
  if is_dynatrace_oneagent_installed; then
    echo "---> ENABLE_DYNATRACE=true, but Dynarace OneAgent already exists in $DT_ONEAGENT_INSTALL_DIR. Skipping installation."
    return 1
  fi

  if [ -z $DT_TENANT ] || [ -z $DT_API_TOKEN ]; then
    echo "---> Warning: ENABLE_DYNATRACE=true, but DT_TENANT and DT_API_TOKEN have not been defined."
    return 1
  fi

  return 0
}

if should_install_dynatrace_oneagent; then
  install_dynatrace_oneagent
fi

if is_dynatrace_oneagent_installed; then
  inject_dynatrace_oneagent
fi
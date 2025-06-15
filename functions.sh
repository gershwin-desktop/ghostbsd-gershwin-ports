#!/bin/sh

main() {
  export POUDRIERE_ETC="/zroot/gnustep-build/etc"
  check_requirements
}

check_requirements() {
  if [ "$(id -u)" != "0" ]; then
    echo "Must be run as root"
    exit 1
  fi
  for cmd in git poudriere; do
    command -v "$cmd" >/dev/null 2>&1 || {
      echo "$cmd is required but not found"
      exit 1
    }
  done
}

create_datasets() {
  base="zroot/gnustep-build"

  for ds in "$base" "$base/etc" "$base/distfiles"; do
    mount="/$ds"

    if ! zfs list -H -o name "$ds" >/dev/null 2>&1; then
      zfs create -o mountpoint="$mount" "$ds"
    fi
  done
}

install_poudriere_conf() {
  [ -f "$POUDRIERE_ETC/poudriere.conf" ] || cp ./poudriere.conf "$POUDRIERE_ETC/poudriere.conf"
}

poudriere_jail() {
  jailname="gnustep_base"
  jailversion="14.2-RELEASE"

  if ! poudriere -e "$POUDRIERE_ETC" jail -l | grep -q "^$jailname"; then
    poudriere -e "$POUDRIERE_ETC" jail -c \
      -j "$jailname" \
      -m src=/usr/src \
      -v "$jailversion" \
      -a amd64
  else
    echo "Jail '$jailname' already exists. Skipping creation."
  fi
}

poudriere_ports() {
  if ! poudriere -e "$POUDRIERE_ETC" ports -l | grep -q gnustep_ports; then
    poudriere -e "$POUDRIERE_ETC" ports -c -p gnustep_ports -m null -M /usr/ports
  fi
}

read_ports_list() {
  PORTS_LIST=$(awk -F/ '{print $0}' ports.list)
}

install_overlay_ports() {
  read_ports_list

  # Install custom Mk/Uses file
  install -d /usr/ports/Mk/Uses
  install -m 0644 ports-overlay/Mk/Uses/gershwin.mk /usr/ports/Mk/Uses/gershwin.mk

  # Replace listed ports
  for port in $PORTS_LIST; do
    port_path="/usr/ports/$port"
    overlay_path="ports-overlay/$port"

    [ -d "$port_path" ] && rm -rf "$port_path"
    install -d "$(dirname "$port_path")"
    cp -a "$overlay_path" "$port_path"
  done
}

poudriere_bulk() {
  poudriere -e "$POUDRIERE_ETC" bulk -j gnustep_base -p gnustep_ports -O gnustep_overlay $(cat ports.list)
}

ports_target() {
  main
  create_datasets
  install_poudriere_conf
  poudriere_jail
  poudriere_ports
  install_overlay_ports
  poudriere_bulk
}

clean_zfs() {
  zfs destroy -rf zroot/gnustep-build || echo "Nothing to clean"
  if [ -d /zroot/gnustep-build ] ; then rm -rf /zroot/gnustep-build ; fi

  read_ports_list

  rm -f /usr/ports/Mk/Uses/gershwin.mk 2>/dev/null

  for port in $PORTS_LIST; do
    port_path="/usr/ports/$port"
    rm -rf "$port_path" 2>/dev/null
  done
}
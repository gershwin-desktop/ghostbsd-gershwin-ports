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
    mount="/$ds"  # This expands to /zroot/gnustep-build/etc etc.

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
  jailversion="14.2-RELEASE"  # Match what you're building from /usr/src

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

poudriere_overlay() {
  poudriere -e "$POUDRIERE_ETC" ports -l | grep -q gnustep_overlay || \
    poudriere -e "$POUDRIERE_ETC" ports -c -p gnustep_overlay -m null -M "$(pwd)/ports-overlay"
}

poudriere_bulk() {
  poudriere -e "$POUDRIERE_ETC" bulk -b latest -j gnustep_base -p gnustep_ports -O gnustep_overlay $(cat ports.list)
}

ports_target() {
  main
  create_datasets
  install_poudriere_conf
  poudriere_jail
  poudriere_ports
  poudriere_overlay
  poudriere_bulk
}

clean_zfs() {
  zfs destroy -rf zroot/gnustep-build || echo "Nothing to clean"
  if [ -d /zroot/gnustep-build ] ; then rm -rf /zroot/gnustep-build ; fi
}

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
  local jailname="gnustep_base"
  
  # Source poudriere.conf to get variables
  . "${POUDRIERE_ETC}/poudriere.conf"
  
  # Get system configuration dynamically
  local sys_version=$(uname -r | sed 's/-p[0-9]*//')
  local sys_arch=$(uname -p)
  local abi="FreeBSD:$(uname -r | cut -d. -f1):${sys_arch}"
  
  if ! poudriere -e "$POUDRIERE_ETC" jail -l | grep -q "^${jailname}"; then
    echo "Creating jail '${jailname}' from GhostBSD base packages..."
    
    # Use variables from poudriere.conf
    local JAILPATH="${BASEFS}/jails/${jailname}"
    local JAILFS="${ZPOOL}${ZROOTFS}/jails/${jailname}"
    
    # Create dataset
    zfs create -p -o compression=on -o atime=off -o mountpoint="${JAILPATH}" "${JAILFS}"
    
    # Create essential directories
    for dir in etc/pkg/repos dev proc tmp var/run var/db/pkg usr/share/keys/ssl/certs var/cache/pkg; do
      mkdir -p "${JAILPATH}/${dir}"
    done
    
    # Copy or link host's pkg cache to avoid re-downloading
    if [ -d "/var/cache/pkg" ]; then
      # Copy existing package cache from host
      echo "Copying host pkg cache to jail..."
      cp -a /var/cache/pkg/* "${JAILPATH}/var/cache/pkg/" 2>/dev/null || true
    fi
    
    # Copy GhostBSD pkg configuration
    cp /etc/pkg/GhostBSD.conf "${JAILPATH}/etc/pkg/"
    cp /etc/pkg/GhostBSD.conf "${JAILPATH}/etc/pkg/repos/"
    
    # Copy GhostBSD public key
    if [ -f "/usr/share/keys/ssl/certs/ghostbsd.cert" ]; then
      cp /usr/share/keys/ssl/certs/ghostbsd.cert "${JAILPATH}/usr/share/keys/ssl/certs/"
    fi
    
    # Bootstrap pkg (will use cached packages if available)
    env IGNORE_OSVERSION=yes ABI="${abi}" PKG_CACHEDIR="${JAILPATH}/var/cache/pkg" \
      pkg -r "${JAILPATH}" bootstrap -f -y
    
    # Update pkg database
    pkg -o IGNORE_OSVERSION=yes -o ABI="${abi}" -o PKG_CACHEDIR="${JAILPATH}/var/cache/pkg" \
      -r "${JAILPATH}" update
    
    # Install packages from base.list (using cache)
    if [ -f "base.list" ]; then
      while IFS= read -r pkg; do
        case "$pkg" in
          "#"*|"") continue ;;
        esac
        echo "Installing ${pkg}..."
        pkg -o IGNORE_OSVERSION=yes -o ABI="${abi}" -o PKG_CACHEDIR="${JAILPATH}/var/cache/pkg" \
          -r "${JAILPATH}" install -y ${pkg} || true
      done < base.list
    fi
    
    # Copy any new packages back to host cache for future use
    if [ -d "${JAILPATH}/var/cache/pkg" ]; then
      echo "Updating host pkg cache with any new packages..."
      cp -an "${JAILPATH}/var/cache/pkg/"* /var/cache/pkg/ 2>/dev/null || true
    fi
    
    # Register jail with poudriere
    local POUDRIERED="${POUDRIERE_ETC}/poudriere.d"
    mkdir -p "${POUDRIERED}/jails/${jailname}"
    
    echo "${JAILFS}" > "${POUDRIERED}/jails/${jailname}/fs"
    echo "${sys_version}" > "${POUDRIERED}/jails/${jailname}/version"
    echo "${sys_arch}" > "${POUDRIERED}/jails/${jailname}/arch"
    echo "${JAILPATH}" > "${POUDRIERED}/jails/${jailname}/mnt"
    echo "pkgbase" > "${POUDRIERED}/jails/${jailname}/method"
    date +%s > "${POUDRIERED}/jails/${jailname}/timestamp"
    
    # Create clean snapshot
    zfs snapshot "${JAILFS}@clean"
    
    echo "Jail '${jailname}' created successfully"
  else
    echo "Jail '${jailname}' already exists. Skipping creation."
  fi
}

poudriere_ports() {
  if ! poudriere -e "$POUDRIERE_ETC" ports -l | grep -q gnustep_ports; then
    poudriere -e "$POUDRIERE_ETC" ports -c -p gnustep_ports -m null -M /usr/ports
  fi

  if ! poudriere -e "$POUDRIERE_ETC" ports -l | grep -q gnustep_ports_overlay; then
    poudriere -e "$POUDRIERE_ETC" ports -c -p gnustep_ports_overlay -m null -M "${PWD}/ports-overlay"
  fi
}

poudriere_bulk() {
  poudriere -e "$POUDRIERE_ETC" bulk -j gnustep_base -p gnustep_ports -O gnustep_ports_overlay -b latest $(cat ports.list)
}

ports_target() {
  main
  create_datasets
  install_poudriere_conf
  poudriere_jail
  poudriere_ports
  poudriere_bulk
}

clean_zfs() {
  zfs destroy -rf zroot/gnustep-build || echo "Nothing to clean"
  if [ -d /zroot/gnustep-build ] ; then rm -rf /zroot/gnustep-build ; fi
}

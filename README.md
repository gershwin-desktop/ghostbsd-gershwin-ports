# ghostbsd-gershwin-ports

This tool is intended for development and testing of all Gershwin related ports for GhostBSD

## Requirements

Install the following packages on GhostBSD:
```
sudo pkg install -g 'GhostBSD*-dev'
sudo pkg install Ghostbsd-src
sudo pkg install Ghostbsd-src-sys
sudo pkg install ports
sudo pkg install poudriere-devel
sudo pkg install portlint
```

Build world and kernel for poudriere jail:
```
cd /usr/src
sudo make -j$(sysctl -n hw.ncpu) buildworld
sudo make -j$(sysctl -n hw.ncpu) buildkernel
```

## Usage

### Port Development Workflow

This system uses `ports.list` to track which overlay ports to install and test with poudriere.

- All ports listed in `ports.list` are copied from `ports-overlay/` to `/usr/ports/` each time `make ports` is run.
- This enables full use of the ports system (`make stage`, `make clean`, `make makeplist`, etc.) with proper dependency resolution.
- When running `make clean`, all ports listed in `ports.list` are removed from `/usr/ports/`, along with the custom `Mk/Uses/gershwin.mk` file.

### Recommended Port Development Steps

1. Create a port directory in `ports-overlay/category/portname/`.
2. Write the initial `Makefile`.
3. Run:
   ```
   sudo make makesum
   portlint
   sudo make stage clean
   sudo make make makeplist > pkg-plist
   ```
4. Once validated, add `category/portname` to `ports.list`.

## Commands

### Build Ports with Poudriere

```
sudo make ports
```

This will:
- Install overlay ports and `gershwin.mk` into `/usr/ports`
- Set up a poudriere jail and port tree (if not already set up)
- Build all ports listed in `ports.list`

### Clean All Overlay Data

```
sudo make clean
```

This will:
- Remove all overlay ports listed in `ports.list` from `/usr/ports`
- Remove `Mk/Uses/gershwin.mk`
- Destroy all poudriere datasets under `/zroot/gnustep-build`
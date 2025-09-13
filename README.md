# ghostbsd-gershwin-ports

This tool is intended for development and testing of all Gershwin related ports for GhostBSD

## Requirements

Install the following packages on GhostBSD:
```
sudo pkg install -g 'GhostBSD*-dev'
sudo pkg install ports
sudo pkg install poudriere-devel
sudo pkg install portlint
```

## Usage

### Port Development Workflow

This system uses `ports.list` to track which overlay ports to install and test with poudriere.

- All ports listed in `ports.list` are mounted from `ports-overlay/` to ports jail each time `make ports` is run.

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

This will:`
- Set up a poudriere jail using pkgbase to install GhostBSD
- Mount /usr/ports to ports jail
- Mount ports-overlay into ports jail
- Build all ports listed in `ports.list`

### Clean All Data

```
sudo make clean
```

This will:
- Destroy all poudriere datasets under `/zroot/gnustep-build and leave /usr/ports untouched`

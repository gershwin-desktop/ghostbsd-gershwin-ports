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
```

Build world and kernel for poudriere jail:
```
cd /usr/src
sudo make -j$(sysctl -n hw.ncpu) buildworld
sudo make -j$(sysctl -n hw.ncpu) buildkernel
```

## Usage

To build ports defined in ports.list:

```
sudo make ports
```

To cleanup all poudriere related data generated in /zroot/gnustep

```
sudo make clean
```
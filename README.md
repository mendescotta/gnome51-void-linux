# gnome51-void-linux

void-packages templates for GNOME 51 on Void Linux (runit, elogind), plus
Budgie 10.10 ported to it. Split out of the `gnome51` branch of
[mendescotta/void-packages](https://github.com/mendescotta/void-packages).

## Contents

- `srcpkgs/`: updated and new templates with their patches. Copy them over a
  void-packages checkout based on upstream commit c06edb3c22.
- `patches/`: `common/shlibs` changes, in order (`git am` or `git apply`).
- `install-gnome51.sh`: builds and installs the GNOME stack.
- `install-budgie.sh`: builds and installs Budgie on top of it.

Both scripts take `-n` to preview the commands and `-d dir` to pick the
checkout. They clone the `gnome51` branch of the fork above, not this repo.

## GNOME 51

```
./install-gnome51.sh -n      # preview
./install-gnome51.sh -e      # build, install, switch the display manager to GDM
./install-gnome51.sh -r      # also build runit-settingsd
```

- Settings stays at 50 and Files (Nautilus) at 50.2.2: Settings 51 needs
  GTK 4.23 and Nautilus 51 needs GTK 4.24 with GLib 2.89. Epiphany stays at
  50.6 because 51 does not build against WebKitGTK 2.50.4.
- accountsservice is updated to 26.27.3 (Initial Setup 51), and gvfs 1.62
  needs msgraph 0.3.
- GNOME Logs needs libsystemd and is not provided.
- `runit-settingsd` (optional) provides the hostname1, timedate1 and locale1
  D-Bus services Settings expects.
- The gnome-desktop ABI change means installed consumers must be rebuilt; the
  installer does this.
- Removed, not ported: Magpie, GNOME Flashback and gnome-screensaver.
  `removed-packages` handles the upgrade.
- XSETTINGS startup is still missing; musl and cross builds are untested.

## Budgie

```
./install-gnome51.sh          # first, for the GNOME 51 libraries
./install-budgie.sh -n        # preview
./install-budgie.sh
```

Budgie 10.10 no longer needs Magpie and runs on Wayland with labwc, so it
builds against GNOME 51: budgie-desktop 10.10.4, budgie-control-center 2.1.3,
budgie-desktop-view 10.10.3 and budgie-session 1.0.1. budgie-screensaver is
dropped: it is an X11-only fork of gnome-screensaver, and Budgie 10.10
depends on swaylock and swayidle instead.

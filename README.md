# gnome51-void-linux

void-packages templates for GNOME 51 on Void Linux (runit, elogind), plus
Budgie 10.10 ported to it. Split out of the `gnome51` branch of
[mendescotta/void-packages](https://github.com/mendescotta/void-packages).

## Contents

- `srcpkgs/`: updated and new templates with their patches, built
  on a stock Void system (void-packages master, 2026-11-25). Replace each
  matching directory in a void-packages checkout (remove it first, so Void's
  old patches do not linger; Apostrophe 3.5 fails with Void's 2.6 patch).
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
  GTK 4.23 and Nautilus 51 needs GTK 4.24 with GLib 2.89.
- WebKitGTK is updated to 2.54.3 (libwebkit2gtk41 and libwebkitgtk60), which
  Web (Epiphany) 51.3 needs.
- accountsservice is updated to 26.27.3 (Initial Setup 51).
- GNOME Logs needs libsystemd and is not provided.
- GNOME apps are bumped to the newest release that builds against the GTK,
  GLib and libadwaita official Void ships (for example Nautilus and Settings
  50.4), not to 51. The soname bumps in `patches/0009` (evolution-data-server
  3.62, gedit libraries) mean `gnome-shell`, `gnome-calendar`,
  `gnome-contacts` and other dependents must be rebuilt.
- Not carried: gnome-panel, metacity, openbox, pidgin, planify and
  io.elementary.calendar. Void's builds of gnome-panel, pidgin, planify and
  io.elementary.calendar link the evolution-data-server (and, for
  gnome-panel, gnome-desktop) libraries bumped here, so `removed-packages`
  (Void's list plus those and the dropped Budgie/flashback pieces) uninstalls
  them.
- `runit-settingsd` (optional) provides the hostname1, timedate1 and locale1
  D-Bus services Settings expects.

## Apps

Besides the GNOME 51 stack: Maps 51.3, Manuals 50.1 (with its library
foundry 1.2.0; shlibs in `patches/0010`), and the GNOME Circle apps
Apostrophe 3.5 (GTK 4 rewrite), Citations 0.10.0, NewsFlash 6.0.2, Pika Backup
0.8.4 and Wike 3.2.1. Citations stays at 0.10.0 because 0.11 needs GTK 4.23.

## Budgie

```
./install-gnome51.sh          # first, for the GNOME 51 libraries
./install-budgie.sh -n        # preview
./install-budgie.sh
```

Budgie 10.10 no longer needs Magpie and runs on Wayland with labwc, so it
builds against GNOME 51: budgie-desktop 10.10.4, budgie-control-center 2.1.3,
budgie-desktop-view 10.10.3 and budgie-extras 2.3.1, with Void's
budgie-session 1.0.1
(built with `-Dfor-wayland=true`; the budgie shlibs patch in `patches/` is
required). budgie-screensaver is dropped: it is an X11-only fork of gnome-screensaver, and Budgie 10.10
depends on swaylock and swayidle instead.

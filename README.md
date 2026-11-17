# gnome51-void-linux

Clean void-packages templates for the GNOME 51 stack, split out of the
`gnome51` branch of [mendescotta/void-packages](https://github.com/mendescotta/void-packages).

- `srcpkgs/`: updated or new templates (with their patches and files). Copy
  them over a void-packages checkout; the base is upstream commit c06edb3c22.
- `patches/`: `common/shlibs` changes, in order. Apply with `git am` or
  `git apply` in a void-packages checkout.
- `install-gnome51.sh`: builds and installs the stack. It still clones the
  `gnome51` branch of the fork above; it does not use this repository.

Magpie, GNOME Flashback and gnome-screensaver are removed, not ported;
`srcpkgs/removed-packages` handles the upgrade. Budgie is kept: 10.10 no
longer needs Magpie (it runs on labwc), and budgie-desktop 10.10.4,
budgie-control-center 2.1.3, budgie-desktop-view 10.10.3, budgie-session
1.0.1 and budgie-screensaver 5.1.0 build against GNOME 51. They are built but
not yet tested in a running session.

---

# GNOME 51 on Void Linux

- GNOME 51 for runit and elogind, with Void’s existing platform libraries.
- Settings stays at 50 and Files (Nautilus) at 50.2.2: Control Center 51
  needs GTK 4.23, while Nautilus 51 needs GTK 4.24 and GLib 2.89. Epiphany 51
  does not build against Void's WebKitGTK 2.50.4 API, so it stays at 50.6.
- Initial Setup 51 needs AccountsService 26.12 (soname 1), so accountsservice
  is updated to 26.27.3. gvfs 1.62 needs msgraph 0.3 (soname 1), and enables
  the deprecated AFP backend to keep gvfs-afp.
- GNOME Logs needs libsystemd and has no runit-compatible setup.
- `runit-settingsd` is optional. It provides the hostname1, timedate1 and
  locale1 D-Bus services for Settings; build it with `./xbps-src pkg
  runit-settingsd`, or pass `-r` to the installer.
- Small compatibility patches support elogind 252, session startup without
  systemd, autostart conditions and IBus 1.5.32.
- Build with `./xbps-src binary-bootstrap`, then `./xbps-src pkg gnome-core`
  and `./xbps-src pkg gdm`. Packages go in `hostdir/binpkgs/gnome51`.
- `./install-gnome51.sh -n` previews the build and install commands.
  Run without `-n` to install; `-e` also switches the display manager to GDM.
- The gnome-desktop ABI change requires rebuilding installed consumers.
  The installer handles these. Updating `removed-packages` removes Magpie,
  GNOME Flashback and gnome-screensaver.
- XSETTINGS startup is still missing; musl and cross builds are untested.
- See [Manual.md](Manual.md) for packaging details.

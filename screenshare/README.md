# Mango screen sharing

This snapshot includes the current Rofi portal picker and the previously tested
xdg-desktop-portal-wlr **0.8.4** window-capture fix. On the reference Intel/NVIDIA
laptop, Discord window shares were skewed with DMA-BUF frames. The patch uses
shared-memory frames for windows while retaining DMA-BUF for monitor capture.
It can increase CPU usage for window sharing. The reverted `force_mod_linear`
experiment is not included.

## Files and setup

- `config/xdg-desktop-portal-wlr/`: copy to
  `~/.config/xdg-desktop-portal-wlr/`. The live Mango config points to this shared
  directory through a symlink. The config uses an absolute `/home/gentoo` path;
  adjust it for another user.
- `scripts/rofi-focused`: install executable at `~/.local/bin/rofi-focused`.
  Requires Rofi and Python 3; optional Sway output detection uses `swaymsg`.
- `screenshare/org.freedesktop.impl.portal.desktop.wlr.service`: reference copy
  of the active user D-Bus service, installed under
  `~/.local/share/dbus-1/services/`. Adjust its absolute executable path.
- `patches/xdg-desktop-portal-wlr-0.8.4-window-shm.patch`: version-specific patch.
  Upstream's MIT license is retained under `licenses/`.

Rebuild from the repository root, after reviewing the script:

```sh
./scripts/build-window-share-portal.sh
```

Requires Git, Meson, Ninja, a C compiler, pkg-config and upstream portal build
dependencies (including Wayland, PipeWire and libdrm/GBM headers). The script
backs up an existing user-local executable before installing its replacement.
It does not install system dependencies, change your session or restart portals.
Do not apply this patch to a newer release without review.

Stop any active share, then log out and back in before testing a new window share.
The main `xdg-desktop-portal` service and a suitable fallback such as the GTK
backend are also required. If backend selection needs explicit configuration,
merge the following into `mango-portals.conf` under the session's
`$XDG_CONFIG_HOME/xdg-desktop-portal/` (the current live directory is empty):

```ini
[preferred]
default=gtk
org.freedesktop.impl.portal.ScreenCast=wlr
org.freedesktop.impl.portal.Screenshot=wlr
```

The picker contains optional Vesktop source-reuse support through transient files
in `$XDG_RUNTIME_DIR`. The companion Vesktop modification is not bundled; normal
interactive picking does not require it. The obsolete broken `window-chooser`
symlink, runtime selections/traces, account profiles and compiled binaries are
intentionally excluded.

To undo the capture patch, restore your backed-up portal executable or rebuild
vanilla upstream v0.8.4, then restart the session with no active share.

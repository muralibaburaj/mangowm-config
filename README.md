# MangoWM configuration — Gentoo fork

Fork of [Kevin Santamaria's mango-dotfiles](https://github.com/kevsantamaria/mango-dotfiles),
with my current Gentoo/MangoWM customizations layered over the original history.
The original MIT license, author credit, wallpapers, and upstream assets are retained.
The upstream Waybar design credits [HANCORE-linux](https://github.com/HANCORE-linux/waybar-themes#v14).

This is a **separate MangoWM repo**, not Zephyr (my Sway setup).
Creating this repository does not install anything or change either live session.

## Gentoo customization snapshot

- Current Mango keybindings, layouts, animations, and dual-monitor rules.
- Foot, Rofi, Waybar, SwayNC, Swaylock, Wlogout, and Fastfetch configuration.
- Neovim, btop, Impala, Lazygit, Yazi, and Zathura configuration.
- Mango desktop-service, night-light, window-control, and Bluetooth helper scripts.
- PipeWire/WirePlumber audio, Impala/iwd networking, and `loginctl` power actions.
- Clipboard screenshots using Grim, Slurp, and wl-clipboard.

Only selected configuration and source scripts are included. Browser/account profiles,
credentials, clipboard history, application databases, caches, backup directories,
and personal note synchronization are excluded.

## Layout and local assumptions

`config/` follows the upstream layout. Its contents correspond to the applications
inside my Mango-only config root, currently `~/.config/mango/` (also accessible through
`~/.config/mango-session`). `scripts/` contains helpers used from `~/.local/bin/`.

This is a snapshot of the working setup, **not a portable automatic installer**.
Some paths still reference `/home/gentoo`, `~/.local/share/mango-dotfiles`, or locally
installed application wrappers. Review those paths, dependencies, and monitor rules
before installing elsewhere. The `zen`/`nnn` wrappers, optional speaker auto-mute
helper, and locally installed `wlsunset` executable are not bundled.

The upstream shell settings, screenshot, and unused assets are kept for provenance;
the screenshot and original dependency list below describe the upstream setup,
not necessarily this Gentoo snapshot. No package installation/removal is automated.

## Keeping upstream credit and history

The GitHub repository is a real fork. Locally, `origin` points to this fork and
`upstream` points to `kevsantamaria/mango-dotfiles`. To inspect upstream changes:

```sh
git fetch upstream
git log --oneline HEAD..upstream/main
```

Merge upstream deliberately after reviewing conflicts; do not overwrite your live
configuration blindly.

---

## Original upstream README

<p align="center">
<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Silkscreen&size=75&duration=5000&pause=2000&color=a292a3&background=181616&center=true&vCenter=true&width=600&height=150&lines=mango-dots" alt="Dotfiles Banner" /></a>
<br/>
        <img src="https://img.shields.io/badge/mangowm%20-%20WM?style=for-the-badge&label=WM&labelColor=%2387a987&color=%23c5c9c5" />
        <img src="https://img.shields.io/badge/waybar%20-%20BAR?style=for-the-badge&label=BAR&labelColor=%23c4746e&color=%23c5c9c5" />
        <img src="https://img.shields.io/badge/foot%20-%20TERMINAL?style=for-the-badge&label=TERMINAL&labelColor=%237e9cd8&color=%23181616"/>
        <img src="https://img.shields.io/badge/zsh%20-%20SHELL?style=for-the-badge&label=SHELL&labelColor=%23938aa9&color=%23c5c9c5"/>
        <br>
</p>

## Overview

> My personal Arch-based dots for MangoWM. Minimalist style with the Kanagawa Dragon palette. I use awww for the wallpaper, and the Waybar bar is [HANCORE-linux waybar theme 1.4](https://github.com/HANCORE-linux/waybar-themes#v14) adapted to the color palette and incorporating custom modules. The shell is zsh with oh-my-zsh, with a prompt built using Starship, and I use foot as the terminal. I recommend a Nerd Font so everything looks nicer — I use JetBrains Mono Nerd Font.

![Screenshot](screenshot.png)

## Dependencies

| Category                 | Packages                                |
| ------------------------ | --------------------------------------- |
| **Window Manager**       | mango                                   |
| **Status Bar & Widgets** | waybar, awww                            |
| **Terminal**             | foot, fastfetch                         |
| **Launchers**            | rofi, rofi-bluetooth, networkmanager    |
| **Lock & Session**       | swaylock, wlogout, swayidle             |
| **Notifications**        | swaync                                  |
| **Audio**                | pulseaudio, pamixer, pavucontrol        |
| **Display & Power**      | brightnessctl, power-profiles-daemon    |
| **Clipboard**            | wl-clipboard, cliphist, wl-clip-persist |
| **Screenshots**          | grim, slurp, wayfreeze, satty           |
| **Utilities**            | ncdu, upower, wlsunset, jq              |
| **Fonts & Theme**        | ttf-jetbrains-mono-nerd                 |
| **System**               | waybar-module-pacman-updates, zsh       |

### Cursor

> I use [pxsor](https://github.com/melisapo/pxsor) as my cursor theme.

## Keybinds

| Keybind          | Action                              |
| ---------------- | ----------------------------------- |
| `SUPER + Space`  | App launcher (rofi)                 |
| `SUPER + V`      | Clipboard history (cliphist + rofi) |
| `SUPER + Return` | Terminal (foot)                     |
| `SUPER + E`      | Editor (Zed)                        |
| `SUPER + B`      | Browser (Brave)                     |
| `SUPER + F`      | File manager (Thunar)               |
| `SUPER + O`      | Obsidian                            |

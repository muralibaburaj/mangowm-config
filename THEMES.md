# Appearance recovery inventory

Audited/exported 2026-10-12. Only selected appearance files are included: no
browser profiles, credentials, chat history, editor databases or Obsidian notes.
The audit covers the applications listed below, not every application ever
installed. Restoring identical appearance on another distro requires the listed
fonts, packages and compatible app versions. No live settings were changed.

## Files and destinations

| Application | Included appearance | Restore destination / dependency |
| --- | --- | --- |
| Mango, Foot, Rofi, Waybar, SwayNC, lock/logout | Existing `config/<app>/` | `~/.config/mango/<app>/`; corresponding applications |
| Wallpaper | `wallpapers/0017.png` | `~/.local/share/mango-dotfiles/wallpapers/0017.png` |
| Neovim | `config/nvim/lua/plugins/kanagawa.lua` and editor config | Kanagawa Dragon via `rebelot/kanagawa.nvim`; install plugin using LazyVim/Lazy |
| btop, Yazi, Zathura | Existing `config/` theme files | Matching Mango config directories |
| OpenCode V2 | `config/opencode/cli.json`, `themes/kanagawa-dragon.json` | `$XDG_CONFIG_HOME/opencode/`; no provider/MCP/account configuration included |
| VSCodium | `templates/vscodium/appearance-settings.json` | Merge into `~/.config/mango/VSCodium/User/settings.json`; do not replace other settings |
| VSCodium base theme | `assets/vscodium/kanagawa-flavors/` | `metaphore.kanagawa-vscode-color-theme` 0.5.0; select **Kanagawa Dragon** |
| Zed | `config/zed/settings.json`, `themes/Kanagawa*.json` | Merge appearance settings; put JSON themes in `$XDG_CONFIG_HOME/zed/themes/` |
| Helix | `config/helix/config.toml` | Built-in `kanagawa-dragon` in a compatible Helix release |
| Alacritty | `config/alacritty/alacritty.toml` | Existing Catppuccin-style palette, preserved rather than recolored |
| Discord/Vencord | `themes/discord/quickCss.css`, SCSS source | Vencord QuickCSS; live reference path `~/.config/Vencord/settings/quickCss.css` |
| Vesktop (optional) | `themes/vesktop/quickCss.css` | `~/.config/vesktop/settings/quickCss.css`; stored Mango theme, not an active client |
| Zen | `templates/zen/chrome/` plus appearance-only `user.js` | Merge into the **active profile**, found through `about:profiles`; never copy a whole profile |
| Obsidian | `templates/obsidian/.obsidian/` | Merge into a vault only when explicitly desired; current theme **Kanagawa Paper 2.0.0** |
| GTK | `config/gtk-3.0/settings.ini` | Appearance-only template generated from observed settings; GTK Adwaita dark |
| Icons/cursor | Dependency, not vendored binaries | **Adwaita**; Mango cursor size 24 |

## Restore safely

Back up conflicting files first, close the affected applications, and merge
settings rather than bulk-copying templates over existing user configuration.
The session currently uses `XDG_CONFIG_HOME=$HOME/.config/mango`; account apps
such as Discord and Zen may explicitly use the ordinary `~/.config` instead.
Review application paths rather than assuming everything goes under Mango.

### VSCodium and Zed

Install the VSCodium extension above from Open VSX, then merge the exported
`workbench.colorTheme` and `workbench.colorCustomizations`. The vendored extension
contains its original theme JSON, icon, package metadata and MIT license, without
local installation metadata. It can be packaged as a VSIX with VS Code's `vsce`
tool for offline recovery. This repo does not contain unrelated extensions.

Zed's active dark theme is **Kanagawa Dragon - No Italics**, from
`ethangilmore/zed-kanagawa` extension 0.1.2. Its two theme files are included as
custom themes. The configured light fallback is **Gruvbox Light**; install that
theme separately if it is not supplied by your Zed installation. There are no
custom local Gruvbox files to export.

### Discord and Zen

Vencord's CSS is the current compiled theme, not merely the small fallback
palette. Enable QuickCSS in Vencord. Existing enabled/cloud-synced themes can
override it: review those controls in the UI, without replacing your account
settings JSON. The SCSS rebuild needs Catppuccin Discord source at commit
`b9b5547`; the compiled CSS works without Sass.

Zen's CSS references `zen-logo-kanagawa.svg`, which is included. Copy only the
three files in `templates/zen/chrome/` into the active profile's `chrome/`
directory after backup, and merge the six appearance preferences from `user.js`.
No cookies, bookmarks, saved passwords, `prefs.js` or profile identifiers are
included. Restart Zen. The generated Zen Mods file was empty and is not needed
for this captured styling.

### Obsidian

The captured appearance selects **Kanagawa Paper**, dark mode, with no enabled
CSS snippets. The old `kanagawa-dragon.css` snippet is retained as an **inactive**
optional file; do not enable it merely because it is present. It was originally
written for Hokusai and is not the current Paper theme configuration.

The repo never changes a live vault. Copy/merge this template only after backing
up the target vault settings. Do not replace its plugin configuration or notes.

### GTK, cursor and fonts

Install Adwaita GTK/icon/cursor support through the distro. For GTK4 apps also
set the desktop's dark preference; the GTK3 template alone does not configure
libadwaita. Observed GSettings selections were `Adwaita-dark`, icons/cursor
`Adwaita`, `Adwaita Sans 11` and `prefer-dark`. Mango itself already selects
`cursor_theme=Adwaita` and `cursor_size=24`. The upstream README's pxsor cursor
is **not** the current cursor.

Install these font families (font binaries are not committed):

- **JetBrains Mono**, including SemiBold (Foot uses size 11; Alacritty size 14).
- **JetBrainsMono Nerd Font Propo** (Rofi size 10, Waybar/SwayNC/Wlogout).
- **Symbols Nerd Font / Symbols Nerd Font Mono**, for icon fallback.
- **Iosevka Nerd Font Propo**, retained as an available secondary family.
- **Noto Sans CJK JP**, **Noto Color Emoji**, **Noto Sans Symbols** and
  **Noto Sans Symbols2**, for CJK separators, emoji and symbol fallback.
- **Adwaita Sans**, plus Liberation/DejaVu families for desktop fallbacks.

After installing fonts, run `fc-cache -f` and check:

```sh
fc-match 'JetBrains Mono:style=SemiBold'
fc-match 'JetBrainsMono Nerd Font Propo'
fc-match 'Symbols Nerd Font Mono'
```

Nerd Font versions/family names can differ between distros. Verify that these
queries resolve to the intended families rather than silently accepting fallback.
The local fonts were installed from mixed system and user directories; a private
home backup should still retain user font files if exact version matching matters.

## Attribution and scope

- VSCodium: [metapho-re/kanagawa-vscode-theme](https://github.com/metapho-re/kanagawa-vscode-theme), MIT license beside vendored assets.
- Zed: [ethangilmore/zed-kanagawa](https://github.com/ethangilmore/zed-kanagawa), `licenses/zed-kanagawa.MIT`.
- Obsidian: [sspaeti/obsidian_kanagawa_paper](https://github.com/sspaeti/obsidian_kanagawa_paper), `licenses/obsidian-kanagawa-paper.MIT`.
- Discord: Catppuccin Discord selectors with the Kanagawa palette; `licenses/catppuccin-discord.MIT`.
- Neovim: upstream `rebelot/kanagawa.nvim` remains a fetched plugin dependency.

Fuzzel's old config symlink is broken and no live custom file could be recovered;
the active launcher is Rofi. No custom mpv theme files were present. This export
is **not** a full application or personal-data backup and does not establish
that all themes have been tested on NixOS.

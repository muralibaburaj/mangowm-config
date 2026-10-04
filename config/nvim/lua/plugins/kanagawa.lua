return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      theme = "dragon",
      dimInactive = false,
      transparent = false,
      colors = {
        theme = {
          all = {
            ui = {
              bg_dim = "#181616",
              bg_m3 = "#181616",
              bg_m2 = "#181616",
              bg_m1 = "#181616",
              bg_gutter = "#181616",
              fg_dim = "#c5c9c5",
              float = { bg = "#181616", bg_border = "#181616", fg = "#c5c9c5" },
            },
          },
        },
      },
      overrides = function(colors)
        local ui = colors.theme.ui
        return {
          CursorLine = { bg = "#1D1C19" },
          CursorColumn = { bg = "#1D1C19" },
          CursorLineSign = { fg = ui.special, bg = ui.bg },
          CursorLineFold = { fg = ui.nontext, bg = ui.bg },
          WinSeparator = { fg = "#393836", bg = ui.bg },
          VertSplit = { fg = "#393836", bg = ui.bg },
          NormalNC = { fg = ui.fg, bg = ui.bg },
          NormalFloat = { fg = ui.fg, bg = ui.bg },
          FloatBorder = { fg = ui.float.fg_border, bg = ui.bg },
        }
      end,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "kanagawa-dragon" } },
}

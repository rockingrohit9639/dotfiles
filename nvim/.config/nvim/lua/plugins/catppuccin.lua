-- Catppuccin Mocha recoloured with the Herdr app's default dark theme,
-- "graphite", so nvim blends into Herdr's terminals.
--
-- Recolouring catppuccin (rather than writing a colorscheme from scratch)
-- keeps LazyVim's catppuccin integrations: bufferline, telescope, neo-tree,
-- gitsigns, which-key, etc. all pick these colours up.
--
-- The hex values are graphite's as Herdr reports them through a mod's
-- theme(). Each comment names the graphite colour a value comes from.
-- Graphite has no orange, so peach uses its "working" amber.
local graphite = {
  rosewater = "#f0f0f2", -- ansi15
  flamingo = "#f0a5ad", -- ansi9
  pink = "#cbb7e6", -- ansi13
  mauve = "#b5a2ce", -- ansi5
  red = "#dc8c95", -- ansi1
  maroon = "#f0a5ad", -- ansi9
  peach = "#e5c07b", -- working
  yellow = "#d8be87", -- ansi3
  green = "#a6bd91", -- ansi2
  teal = "#8cbdc3", -- ansi6
  sky = "#a4d5db", -- ansi14
  sapphire = "#76a8ff", -- done
  blue = "#96b2d7", -- ansi4 / accent
  lavender = "#b0cbef", -- ansi12
  text = "#eeeeef", -- foreground
  subtext1 = "#d2d4d9", -- terminal_foreground
  subtext0 = "#adaeb0", -- ring
  overlay2 = "#98999b", -- muted
  overlay1 = "#818793", -- ansi8
  overlay0 = "#696a6d", -- dim
  surface2 = "#45484f", -- ansi0
  surface1 = "#2c2e31", -- raised
  surface0 = "#25272b", -- popover
  base = "#17191d", -- background (terminals)
  mantle = "#131518", -- canvas
  crust = "#101114", -- chrome (sidebars)
}

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    -- opts (not config) so these merge with LazyVim's own catppuccin spec
    opts = {
      flavour = "mocha",
      color_overrides = { mocha = graphite },
      custom_highlights = function()
        return {
          Visual = { bg = "#394454" }, -- graphite's selection
        }
      end,
    },
  },
  -- LazyVim applies its colorscheme after plugins load, so it has to be told;
  -- a bare `vim.cmd.colorscheme` here gets replaced by tokyonight.
  -- Name the flavour: on startup a bare "catppuccin" comes up in stock Mocha
  -- colours, ignoring color_overrides, while "catppuccin-mocha" applies them.
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-mocha" },
  },
}

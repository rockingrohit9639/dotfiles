return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        -- follow the colorscheme (graphite-coloured catppuccin, see catppuccin.lua)
        theme = 'auto'
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
            shorting_target = 40,
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
            },
          },
        },
      },
    })
  end
}

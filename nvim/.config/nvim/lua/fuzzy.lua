local telescope = require('telescope')

telescope.setup {
  pickers = {
    find_files = {
         find_command = {'rg', '--files', '--hidden', '-g', '!.git'},
    }
  }
}

telescope.load_extension('fzf')

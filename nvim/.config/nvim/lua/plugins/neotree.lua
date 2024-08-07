local function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function (prompt_bufnr, map)
      local actions = require "telescope.actions"
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require "telescope.actions.state"
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if (filename == nil) then
          filename = selection[1]
        end
        require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
      end)
      return true
    end
  }
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },

  config = function() 
    vim.keymap.set('n', '<C-e>', ':Neotree filesystem reveal right<CR>', {})

    require('neo-tree').setup {
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = {},
        },
      },
      commands = {
        telescope_find = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          require('telescope.builtin').find_files(getTelescopeOpts(state, path))
        end,
        telescope_grep = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
        end,
      },
      event_handlers = {
        {
          event = "file_open_requested",
          handler = function()
            -- auto close neo-tree on file open
            require("neo-tree.command").execute({ action = "close" })
          end
        },
      }
    }
  end
}

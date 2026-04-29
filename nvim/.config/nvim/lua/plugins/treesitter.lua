return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local config = require("nvim-treesitter.configs")
            config.setup({
                -- auto_install: Automatically install missing parsers when entering buffer
                auto_install = true, 
                
                -- highlight: usage of treesitter for syntax highlighting
                highlight = { enable = true },
                
                -- indent: experimental, but generally works well
                indent = { enable = true },
                
                -- sync_install: changed to false! True freezes neovim during startup
                sync_install = false, 
                
                -- ensure_installed: list of parsers to install
                ensure_installed = {
                    "javascript",
                    "typescript",
                    "css",
                    "gitignore",
                    "http",
                    "json",
                    "scss",
                    "sql",
                    "vim",
                    "lua",
                    "markdown", -- Highly recommended to add this
                    "markdown_inline" -- Highly recommended to add this
                },
                
                -- REMOVED: query_linter (See explanation below)
            })
        end,
    },
}

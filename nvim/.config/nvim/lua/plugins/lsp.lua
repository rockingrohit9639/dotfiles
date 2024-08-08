return {
  {
    "williamboman/mason.nvim",
    config = function()
      require('mason').setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "tsserver", "astro", "bashls", "ast_grep", "dockerls", "gopls", "html", "biome", "harper_ls", "prismals", "sqlls", "grammarly" }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.tsserver.setup({})
      lspconfig.astro.setup({})
      lspconfig.bashls.setup({})
      lspconfig.ast_grep.setup({})
      lspconfig.dockerls.setup({})
      lspconfig.gopls.setup({})
      lspconfig.html.setup({})
      lspconfig.biome.setup({})
      lspconfig.harper_ls.setup({})
      lspconfig.prismals.setup({})
      lspconfig.sqlls.setup({})
      lspconfig.grammarly.setup({})

      -- Setting up shortcut keys for lsp
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end
  }
}

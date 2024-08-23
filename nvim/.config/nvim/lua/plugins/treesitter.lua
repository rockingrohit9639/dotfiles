return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local config = require("nvim-treesitter.configs")
			config.setup({
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
				sync_install = true,
				modules = {},
				ignore_install = {},
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
				},
				query_linter = {
					enable = true,
					use_virtual_text = true,
					line_events = { "BufWrite", "CursorHold" },
				},
			})
		end,
	},
}

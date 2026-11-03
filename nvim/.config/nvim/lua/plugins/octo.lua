-- GitHub PR and issue review inside Neovim. Octo shells out to the `gh` CLI for
-- every API call, so it inherits whatever account `gh auth status` reports --
-- there is no separate token to configure here.
return {
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>gop", "<cmd>Octo pr list<cr>", desc = "Octo: PR list" },
			{ "<leader>goP", "<cmd>Octo pr search<cr>", desc = "Octo: PR search" },
			{ "<leader>goc", "<cmd>Octo pr checkout<cr>", desc = "Octo: PR checkout" },
			{ "<leader>gor", "<cmd>Octo review start<cr>", desc = "Octo: review start" },
			{ "<leader>goR", "<cmd>Octo review resume<cr>", desc = "Octo: review resume" },
			{ "<leader>goi", "<cmd>Octo issue list<cr>", desc = "Octo: issue list" },
			{ "<leader>goa", "<cmd>Octo actions<cr>", desc = "Octo: all actions" },
		},
		opts = {
			-- Telescope is the picker this config actually drives (<C-p>, <leader>fg).
			-- fzf-lua and snacks are only installed because LazyVim pulls them in.
			picker = "telescope",
			-- Without this, a `gh` token lacking the read:project scope warns on
			-- every PR the plugin opens.
			suppress_missing_scope = { projects_v2 = true },
			-- Bare `:Octo` lists every builtin action instead of erroring.
			enable_builtin = true,
			-- Right-hand side of a review diff shows the real working-tree file, so
			-- it is editable and the LSP attaches. Octo offers to check the PR branch
			-- out first when you are not already on it.
			use_local_fs = true,
		},
	},
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>go", group = "octo (github)" },
			},
		},
	},
}

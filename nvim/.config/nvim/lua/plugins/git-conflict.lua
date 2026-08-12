return {
	"akinsho/git-conflict.nvim",
	version = "*",
	event = "BufReadPre",
	opts = {
		default_mappings = true, -- co ours, ct theirs, cb both, c0 none, ]x / [x to jump
		default_commands = true,
		-- Must stay false: the plugin calls vim.diagnostic.disable(), removed in nvim 0.11+
		disable_diagnostics = false,
		highlights = {
			current = "DiffText",
			incoming = "DiffAdd",
		},
	},
}

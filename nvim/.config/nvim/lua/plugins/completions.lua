-- Completion is handled by blink.cmp, which LazyVim enables by default. LazyVim
-- force-disables nvim-cmp when blink is active, so an nvim-cmp config here would
-- be dead code and its source plugins (cmp-path, cmp_luasnip) error at startup
-- because `cmp` never loads.
--
-- cmp-nvim-lsp is gone too: requiring it registers an InsertEnter autocmd that
-- calls require("cmp"), which threw "module 'cmp' not found" on every insert.
-- plugins/lsp.lua now takes its capabilities from blink.cmp instead.
--
-- Only the pieces still referenced elsewhere are declared:
--   * LuaSnip + snippets    — snippet engine and collection, consumed by blink
return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
	},
}

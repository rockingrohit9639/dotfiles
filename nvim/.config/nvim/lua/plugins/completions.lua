-- Completion is handled by blink.cmp, which LazyVim enables by default. LazyVim
-- force-disables nvim-cmp when blink is active, so an nvim-cmp config here would
-- be dead code and its source plugins (cmp-path, cmp_luasnip) error at startup
-- because `cmp` never loads.
--
-- Only the pieces still referenced elsewhere are declared:
--   * cmp-nvim-lsp          — plugins/lsp.lua uses its default_capabilities()
--   * LuaSnip + snippets    — snippet engine and collection, consumed by blink
return {
	{
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
	},
}

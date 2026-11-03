-- LazyVim owns the bufferline config (lazyvim/plugins/ui.lua); this only
-- overrides on top of it.
return {
	"akinsho/bufferline.nvim",
	opts = {
		options = {
			-- bufferline runs in the default mode = "buffers", so the main row is
			-- buffers and tabpages get their own indicator strip on the far right
			-- (bare tab numbers, shown only once a second tabpage exists). Drop it.
			show_tab_indicators = false,
		},
	},
}

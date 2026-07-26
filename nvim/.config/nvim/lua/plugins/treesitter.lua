-- nvim-treesitter, `main` branch API (requires Neovim 0.11+).
-- The old `require("nvim-treesitter.configs").setup{...}` entrypoint was removed
-- upstream, so highlighting and indent are wired up by hand below.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({})

			-- Parsers to keep installed
			local ensure_installed = {
				"bash",
				"css",
				"gitignore",
				"html",
				"http",
				"javascript",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"scss",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}

			local installed = ts.get_installed()
			local missing = vim.tbl_filter(function(lang)
				return not vim.tbl_contains(installed, lang)
			end, ensure_installed)
			if #missing > 0 then
				ts.install(missing)
			end

			-- Enable highlighting and treesitter-based indent per buffer, and pull
			-- in a parser on first use (replaces the old `auto_install` option).
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match)
					if not lang then
						return
					end

					if vim.tbl_contains(ts.get_installed(), lang) then
						pcall(vim.treesitter.start, ev.buf, lang)
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					elseif vim.tbl_contains(ts.get_available(), lang) then
						-- fire and forget; the parser is active next time this filetype opens
						ts.install({ lang })
					end
				end,
			})
		end,
	},
}

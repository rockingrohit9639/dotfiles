return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		-- Setting up formatting
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.formatting.prisma_format,
				-- Without a config, eslint_d returns non-JSON and surfaces a
				-- "failed to decode json" diagnostic on every buffer. Biome
				-- projects have no eslint config, so this keeps them quiet.
				require("none-ls.diagnostics.eslint_d").with({
					condition = function(utils)
						return utils.root_has_file({
							".eslintrc",
							".eslintrc.js",
							".eslintrc.cjs",
							".eslintrc.json",
							".eslintrc.yaml",
							".eslintrc.yml",
							"eslint.config.js",
							"eslint.config.mjs",
							"eslint.config.cjs",
							"eslint.config.ts",
						})
					end,
				}),
			},
			on_attach = function(client, bufnr)
				-- Formatting on save
				if client:supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							-- Exactly one client may rewrite the buffer. biome owns
							-- projects that opt into it, null-ls (prettier/stylua)
							-- owns the rest. ts_ls also advertises formatting and
							-- must never win.
							local biome = vim.lsp.get_clients({ bufnr = bufnr, name = "biome" })[1]
							vim.lsp.buf.format({
								async = false,
								bufnr = bufnr,
								filter = function(c)
									return c.name == (biome and "biome" or "null-ls")
								end,
							})
						end,
					})
				end
			end,
		})

		-- Shortcut key for formatting
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}

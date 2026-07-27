-- Biome — formatter and linter for JS/TS/JSON/CSS projects.
--
-- Lint diagnostics and code actions come from the biome LSP, which is set up in
-- lsp.lua. That server only attaches when a biome config exists somewhere in the
-- file's directory tree (see `workspace_required` in lspconfig's biome config),
-- so biome stays completely inert in projects that don't use it.
--
-- Formatting is done here through conform, gated the same way: biome formats
-- projects that opt into it, prettier keeps formatting everything else. Without
-- this gate both would rewrite the same buffer on save and fight each other.
--
-- The binary itself is installed by install.sh (biome is in MASON_PACKAGES).

local biome_filetypes = {
	"astro",
	"css",
	"graphql",
	"javascript",
	"javascriptreact",
	"json",
	"jsonc",
	"svelte",
	"typescript",
	"typescriptreact",
	"vue",
}

-- conform evaluates `condition` on every format, so cache the upward search
local cache = {}
local function has_biome_config(ctx)
	local dir = ctx.dirname
	if cache[dir] == nil then
		cache[dir] = vim.fs.find({ "biome.json", "biome.jsonc" }, {
			path = dir,
			upward = true,
			type = "file",
			limit = 1,
		})[1] ~= nil
	end
	return cache[dir]
end

return {
	"stevearc/conform.nvim",
	optional = true,
	opts = function(_, opts)
		opts.formatters_by_ft = opts.formatters_by_ft or {}
		for _, ft in ipairs(biome_filetypes) do
			opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
			table.insert(opts.formatters_by_ft[ft], "biome")
		end

		opts.formatters = opts.formatters or {}

		-- Run only where the project opted into biome
		opts.formatters.biome = vim.tbl_deep_extend("force", opts.formatters.biome or {}, {
			condition = function(_, ctx)
				return has_biome_config(ctx)
			end,
		})

		-- ...and stand prettier down there, preserving the condition LazyVim's
		-- prettier extra already set for every other project
		local prettier = opts.formatters.prettier or {}
		local prettier_condition = prettier.condition
		opts.formatters.prettier = vim.tbl_deep_extend("force", prettier, {
			condition = function(self, ctx)
				if has_biome_config(ctx) then
					return false
				end
				return prettier_condition == nil or prettier_condition(self, ctx)
			end,
		})
	end,
}

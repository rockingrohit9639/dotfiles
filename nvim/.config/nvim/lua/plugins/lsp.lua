return {
	{
		"mason-org/mason.nvim",
		opts = {}
	},
	{
		"mason-org/mason.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
		config = function()
			require("mason").setup({
				ensure_installed = {
					"lua_ls",
					"bashls",
					"ast_grep",
					"dockerls",
					"gopls",
					"html",
					"biome",
					"harper_ls",
					"prismals",
					"sqlls",
					"grammarly",
					"tailwindcss",
				},
			})
		end,
	},
	-- LSP Servers
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = true },
			servers = {
				cssls = {},
				tailwindcss = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
				},
				tsserver = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
					single_file_support = false,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
				html = {},
				lua_ls = {
					single_file_support = true,
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
							misc = {
								parameters = {},
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							doc = {
								privateName = { "^_" },
							},
							type = {
								castNumberToInteger = true,
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },
							},
							format = {
								enable = false,
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",
									continuation_indent_size = "2",
								},
							},
						},
					},
				},
			},
			setup = {},
		},
		config = function()
			-- Completion capabilities come from blink.cmp, the engine LazyVim
			-- actually uses. cmp-nvim-lsp must not be required here: loading it
			-- registers an InsertEnter autocmd that calls require("cmp"), and
			-- nvim-cmp is not installed, so every insert throws "module 'cmp'
			-- not found".
			local ok, blink = pcall(require, "blink.cmp")
			local capabilities = ok and blink.get_lsp_capabilities()
				or vim.lsp.protocol.make_client_capabilities()

			-- Effect ships its language service as a tsserver plugin, not as a
			-- standalone LSP, so it rides along inside typescript-language-server.
			-- tsserver refuses to load plugins that a project declares in its own
			-- tsconfig ("local plugin loading" is disabled unless the editor opts
			-- in), so the plugin has to be handed over at startup as a global one,
			-- with `location` pointing at the project that owns the node_modules
			-- copy. Passing it this way also means it works whether or not the
			-- project lists it under compilerOptions.plugins.
			--
			-- Gated on the package actually being installed, so Effect's
			-- diagnostics and refactors stay out of every unrelated TypeScript
			-- project. Opt in per project with:
			--     npm i -D @effect/language-service
			-- In a monorepo the check looks at the resolved project root, so keep
			-- it in the root package.json when node_modules is hoisted.
			local function effect_ls_plugin(root)
				if not root then
					return nil
				end
				local installed = (vim.uv or vim.loop).fs_stat(root .. "/node_modules/@effect/language-service")
				if not installed then
					return nil
				end
				return { name = "@effect/language-service", location = root }
			end

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilites = capabilities,
			})
			lspconfig.tsserver.setup({
				capabilities = capabilities,
				before_init = function(params, config)
					local root = config.root_dir
					if not root and params.workspaceFolders and params.workspaceFolders[1] then
						root = vim.uri_to_fname(params.workspaceFolders[1].uri)
					end

					local plugin = effect_ls_plugin(root)
					if not plugin then
						return
					end

					config.init_options = config.init_options or {}
					local plugins = config.init_options.plugins or {}
					table.insert(plugins, plugin)
					config.init_options.plugins = plugins
				end,
			})
			lspconfig.astro.setup({
				capabilities = capabilities,
			})
			lspconfig.bashls.setup({
				capabilities = capabilities,
			})
			lspconfig.ast_grep.setup({
				capabilities = capabilities,
			})
			lspconfig.dockerls.setup({
				capabilities = capabilities,
			})
			lspconfig.gopls.setup({
				capabilities = capabilities,
			})
			lspconfig.html.setup({
				capabilities = capabilities,
			})
			lspconfig.biome.setup({
				capabilities = capabilities,
			})
			lspconfig.harper_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.prismals.setup({
				capabilities = capabilities,
			})
			lspconfig.sqlls.setup({
				capabilities = capabilities,
			})
			lspconfig.grammarly.setup({
				capabilities = capabilities,
			})

			-- Setting up shortcut keys for lsp
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, {})
		end,
	},
}

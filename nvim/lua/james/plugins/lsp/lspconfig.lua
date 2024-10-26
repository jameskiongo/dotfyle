return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{
			"olrtg/nvim-emmet",
			config = function()
				vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
			end,
		},
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		local py_path = nil
		local opts = { noremap = true, silent = true }
		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			-- set keybinds
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
		end

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- configure html server
		lspconfig["html"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		-- configure typescript server with plugin
		lspconfig["ts_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			opts = {
				-- make sure mason installs the server
				servers = {
					--- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
					--- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
					tsserver = {
						enabled = false,
					},
					ts_ls = {
						enabled = false,
					},
					vtsls = {
						-- explicitly add default filetypes, so that we can extend
						-- them in related extras
						filetypes = {
							"javascript",
							"javascriptreact",
							"javascript.jsx",
							"typescript",
							"typescriptreact",
							"typescript.tsx",
						},
						settings = {
							complete_function_calls = true,
							vtsls = {
								enableMoveToFileCodeAction = true,
								autoUseWorkspaceTsdk = true,
								experimental = {
									completion = {
										enableServerSideFuzzyMatch = true,
									},
								},
							},
							typescript = {
								updateImportsOnFileMove = { enabled = "always" },
								suggest = {
									completeFunctionCalls = true,
								},
								inlayHints = {
									enumMemberValues = { enabled = true },
									functionLikeReturnTypes = { enabled = true },
									parameterNames = { enabled = "literals" },
									parameterTypes = { enabled = true },
									propertyDeclarationTypes = { enabled = true },
									variableTypes = { enabled = false },
								},
							},
						},
						-- keys = {},
					},
				},
				setup = {
					--- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
					--- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
					tsserver = function()
						-- disable tsserver
						return true
					end,
					ts_ls = function()
						-- disable tsserver
						return true
					end,
					vtsls = function(_, opts)
						LazyVim.lsp.on_attach(function(client, buffer)
							client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
								---@type string, string, lsp.Range
								local action, uri, range = unpack(command.arguments)

								local function move(newf)
									client.request("workspace/executeCommand", {
										command = command.command,
										arguments = { action, uri, range, newf },
									})
								end

								local fname = vim.uri_to_fname(uri)
								client.request("workspace/executeCommand", {
									command = "typescript.tsserverRequest",
									arguments = {
										"getMoveToRefactoringFileSuggestions",
										{
											file = fname,
											startLine = range.start.line + 1,
											startOffset = range.start.character + 1,
											endLine = range["end"].line + 1,
											endOffset = range["end"].character + 1,
										},
									},
								}, function(_, result)
									---@type string[]
									local files = result.body.files
									table.insert(files, 1, "Enter new path...")
									vim.ui.select(files, {
										prompt = "Select move destination:",
										format_item = function(f)
											return vim.fn.fnamemodify(f, ":~:.")
										end,
									}, function(f)
										if f and f:find("^Enter new path") then
											vim.ui.input({
												prompt = "Enter move destination:",
												default = vim.fn.fnamemodify(fname, ":h") .. "/",
												completion = "file",
											}, function(newf)
												return newf and move(newf)
											end)
										elseif f then
											move(f)
										end
									end)
								end)
							end
						end, "vtsls")
						-- copy typescript settings to javascript
						opts.settings.javascript =
							vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
					end,
				},
			},
		})

		-- configure css server
		lspconfig["cssls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure tailwindcss server
		lspconfig["tailwindcss"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure svelte server
		lspconfig["svelte"].setup({
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)

				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						if client.name == "svelte" then
							client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
						end
					end,
				})
			end,
		})

		-- configure prisma orm server
		lspconfig["prismals"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure graphql language server
		lspconfig["graphql"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		-- configure emmet language server
		lspconfig["emmet_ls"].setup({
			capabilities = capabilities,
			filetypes = {
				"css",
				"eruby",
				"html",
				"javascript",
				"javascriptreact",
				"less",
				"sass",
				"scss",
				"svelte",
				"pug",
				"typescriptreact",
				"vue",
				"python",
			},
			init_options = {
				html = {
					options = {
						-- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
						["bem.enabled"] = true,
					},
				},
			},
		})

		-- configure python server
		lspconfig["jedi_language_server"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "python" },
		})
		lspconfig["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = { -- custom settings for lua
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})
	end,
}

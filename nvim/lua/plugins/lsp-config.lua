return {
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"bashls",
				"clangd",				-- C and C++
				"html",
				"lua_ls",
				"markdown_oxide",
				"pylsp",				-- Python
				"ts_ls",				-- JS
			}
		}
	},
	{
		"neovim/nvim-lspconfig",

		config = function()
			local configs = require('lspconfig.configs')
			if not configs.c3_lsp then
				configs.c3_lsp = {
					default_config = {
						cmd = {
							os.getenv("HOME")
							.. "/Programming/Go/c3-lsp/server/bin/c3lsp"
						},
						filetypes = { "c3", "c3i" },
						root_dir = function()
							-- Try project.json
							local pr_json = vim.fs.root(0, "project.json")
							if pr_json ~= nil then
								return pr_json
							end
							-- Try git root
							local git_root = vim.fs.root(0, ".git")
							if git_root ~= nil then
								return git_root
							end
							-- Nothing found, assume standalone C3 file
							return vim.fn.getcwd()
						end,
						settings = {
							["diagnostic-delay"] = 50,
						},
						name = "c3_lsp"
					}
				}
			end
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig.bashls.setup({ capabilities = capabilities })
			lspconfig.clangd.setup({ capabilities = capabilities })
			lspconfig.c3_lsp.setup{}
			lspconfig.html.setup({ capabilities = capabilities })
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.markdown_oxide.setup({ capabilities = capabilities })
			lspconfig.pylsp.setup({ capabilities = capabilities })
			lspconfig.ts_ls.setup({ capabilities = capabilities })

			-- Keymaps using Which-key
			local wk = require("which-key")
			wk.add({
				mode = { 'n' },
				{ "<leader>l", group = "Lsp..." },
				{ "<leader>lh", vim.lsp.buf.hover, desc = "Hover" },
				{ "<leader>lr", vim.lsp.buf.rename, desc = "Rename" },
				{ "<leader>ld", vim.lsp.buf.definition, desc = "Jump to definition" },
				{ "<leader>lu", vim.lsp.buf.references, desc = "List all uses in quickfix" },
				{ "<leader>la", vim.lsp.buf.code_action, desc = "Code actions" },
				{ "<leader>lf", vim.lsp.buf.format, desc = "Format buffer" },
				{ "<leader>lj", group = "Jump to ... diagnostic" },
				{
					"<leader>ljn",
					function() vim.diagnostic.goto_next({ float = false }) end,
					desc = "Jump to next diagnostic"
				},
				{
					"<leader>ljp",
					function() vim.diagnostic.goto_prev({ float = false }) end,
					desc = "Jump to previous diagnostic"
				},
				{
					"<leader>le",
					function() vim.diagnostic.open_float({
						scope = "line", border = "rounded"
					}) end,
					desc = "Show diagnostic info",
				},
			})
		end,
	},
}

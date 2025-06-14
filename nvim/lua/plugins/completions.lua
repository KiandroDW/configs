return {
	{
		"hrsh7th/cmp-nvim-lsp",		-- Talks with LSP's for completions
		event = "InsertEnter",
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",	-- Provides the code-snippets
		},
		event = "InsertEnter",
		opts = {
			region_check_events = "CursorHold,InsertLeave",
			delete_check_events = "TextChanged,InsertEnter",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",

		config = function()
			local cmp = require("cmp")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},

				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					['<Tab>'] = cmp.mapping(
						function (fallback)
							local luasnip = require("luasnip")
							if luasnip.expand_or_jumpable() then
								luasnip.expand_or_jump()
							else
								fallback()
							end
						end
					)
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 8 },
					{ name = "luasnip", priority = 7 },
				}, {
					{ name = "buffer", priority = 9 },
				}),

				sorting = {
					comparators = {
						cmp.config.compare.locality,
						cmp.config.compare.recently_used,
						cmp.config.compare.score,
						cmp.config.compare.offset,
						cmp.config.compare.recently_used,
						cmp.config.compare.order,
					},
				},
			})
		end,
	}
}

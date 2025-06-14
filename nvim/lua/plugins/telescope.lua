local function get_ts()
	return require("telescope.builtin")
end

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		},

		keys = {
			{ "<leader>f", group = "Search for..." },
			{ "<leader>ff", function() get_ts().find_files() end,	desc = "Find files" },
			{ "<leader>fg", function() get_ts().live_grep() end,	desc = "Live grep" },
			{ "<leader>fb", function() get_ts().buffers() end, desc = "Search buffers" },
			{ "<leader>fh", function() get_ts().help_tags() end, desc = "Search help-tags" },
			{ "<leader>ft", function() get_ts().treesitter() end, desc = "Search treesitter tokens" },
			{ "<leader>fa", function() get_ts().current_buffer_fuzzy_find() end, desc = "Search anything in buffer" },
			{ "<leader>fd", function() get_ts().diagnostics() end, desc = "Search LSP diagnostics" },

			{
				"<leader>fF",
				function() get_ts().find_files({
					hidden = true,
					no_ignore = true,
				})
				end,
				desc = "Find hidden files"
			},
			{
				"<leader>fm",
				function()
					get_ts().man_pages({
						sections = { "ALL" }
					})
				end,
				desc = "Search man-pages"
			},
			{
				"<leader>fc",
				function ()
					get_ts().find_files({
						cwd = vim.fn.stdpath("config")
					})
				end,
				desc = "Find nvim-config files"
			}
		},

		opts = {
			extensions = {
				fzf = {}
			}
		}
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		event = "VeryLazy",

		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({})
					}
				}
			})

			require("telescope").load_extension("ui-select")
		end,
	},
}

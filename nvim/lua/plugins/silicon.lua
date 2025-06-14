return {
	{
		"michaelrommel/nvim-silicon",
		lazy = true,
		cmd = "Silicon",
		keys = {
			{ "<M-s>", ":Silicon<CR>", mode = 'v' },
		},
		opts = {
				-- font = "JetBrainsMono Nerd Font=34;Noto Color Emoji=34",
				-- font = "PixelCode",
				-- theme = "gruvbox-dark",
				-- background = "#bdae93",
				no_window_controls = true,
				pad_horiz = 10,
				pad_vert = 10,
				to_clipboard = true,
				gobble = true,
				-- num_separator = " ",
				-- line_offset = function()
				-- 	return vim.api.nvim_win_get_cursor(0)[1]
				-- end,
				window_title = function()
					return vim.fn.fnamemodify(
						vim.api.nvim_buf_get_name(
							vim.api.nvim_get_current_buf()
						), ":t"
					)
				end,
		}
	}
}

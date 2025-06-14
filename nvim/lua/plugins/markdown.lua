return {
	{
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = {
			'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim'
		},
		ft = "markdown",
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			render_modes = true,
			code = {
				width = 'block',
				left_pad = 1,
				right_pad = 4,
			},
			heading = {
				width = 'block',
				left_pad = 0,
				right_pad = 4,
			},
		}
	}
}

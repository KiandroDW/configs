return {
	{
		"m4xshen/autoclose.nvim",
		opts = {
			options = {
				disable_when_touch = true,
				disable_command_mode = true,
				pair_spaces = true,
			},
			keys = {
				["/*"] = {
					escape = false,
					close = true,
					pair = "/**/",
					enabled_filetypes = {
						"c", "cpp", "h",
					}
				},
			}
		}
	},
}

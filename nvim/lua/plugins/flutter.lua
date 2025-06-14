return {
	{
		"nvim-flutter/flutter-tools.nvim",
		ft = "dart",
		keys = {
			{
				"<leader>fr",
				function ()
					local tel = require("telescope")
					tel.load_extension("flutter")
					tel.extensions.flutter.commands()
				end,
				desc = "Search flutter commands"
			}
		},
		opts = {
			dev_log = {
				open_cmd = "8split",
			}
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- "stevearc/dressing.nvim"
		},
	}
}

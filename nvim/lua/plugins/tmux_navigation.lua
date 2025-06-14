return {
	{
		"alexghergh/nvim-tmux-navigation",

		config = function()
			local tnav = require("nvim-tmux-navigation")
			local wk = require("which-key")

			wk.add({
				mode = 'n',
				{ "<C-h>",		tnav.NvimTmuxNavigateLeft		},
				{ "<C-j>",		tnav.NvimTmuxNavigateDown		},
				{ "<C-k>",		tnav.NvimTmuxNavigateUp			},
				{ "<C-l>",		tnav.NvimTmuxNavigateRight		},
				{ "<C-\\>",		tnav.NvimTmuxNavigateLastActive	},
				{ "<C-Space>",	tnav.NvimTmuxNavigateNext		},
			})
		end,
	},
}

return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			-- { "<leader>d", group = "Debugging..." },
			{ "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle breakpoint" },
			{ "<leader>dc", "<cmd>DapContinue<CR>", desc = "Continue/start" },
			{ "<leader>ds", "<cmd>DapTerminate<CR>", desc = "Stop debugging" },
			{ "<leader>du", "<cmd>lua require('dap').up()<CR>", desc = "Go up in call stack" },
			{ "<leader>dd", "<cmd>lua require('dap').down()<CR>", desc = "Go down in call stack" },

			-- Keys lay logically for me this way, F5 in middle, F8 above, F2 below
			{ '<F5>', "<cmd>DapStepOver<CR>" },
			{ '<F2>', "<cmd>DapStepInto<CR>" },
			{ '<F8>', "<cmd>DapStepOut<CR>" },

			-- And duplicates for on my laptop keyboard
			{ '<F10>', "<cmd>DapStepOver<CR>" },
			{ '<F9>' , "<cmd>DapStepInto<CR>" },
			{ '<F11>', "<cmd>DapStepOut<CR>" },
		},

		config = function ()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Start DAPUI when needed, and enable mouse
			dap.listeners.before.launch.dapui_config = function()
				vim.opt.splitright = false
				vim.opt.splitbelow = false
				vim.o.mouse = "a"
				dapui.open()
			end
			-- Close DAPUI and disable mouse
			dap.listeners.before.event_terminated.dapui_config = function()
				vim.opt.splitright = true
				vim.opt.splitbelow = true
				vim.o.mouse = ""
				dapui.close()
			end

			-- Load all debug adapters in '/lua/plugins/adapters'
			local dap_adapters_dir = vim.fn.stdpath('config') .. '/lua/plugins/adapters/'
			for _, file in ipairs(vim.fn.readdir(dap_adapters_dir)) do
				local adapter_path = dap_adapters_dir .. file
				if adapter_path:match('%.lua$') then
					dofile(adapter_path)
				end
			end

		end
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		lazy = true,
		opts = {
			expand_lines = false,
			layouts = {
				{
					elements = { "console", "watches", "scopes" },
					size = 0.3,
					position = "right"
				},
				{
					elements = { "repl", "stacks" },
					size = 0.3,
					position = "bottom",
				},
			},
			floating = { border = "rounded" },
		}
	},
	{
		"MunifTanjim/nui.nvim",
		lazy = true,
	},
	{
		"mfussenegger/nvim-dap-python",
		lazy = true,
		config = function ()
			require("dap-python").setup(
				os.getenv("HOME")
				.. "/.local/share/python-debug-venv/bin/python"
			)
		end,
	},
}

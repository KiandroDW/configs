-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)


vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup lazy.nvim
require("lazy").setup({
	rocks = {
		enabled = false,
	},

	spec = {
		-- import your plugins (so under the plugins/ directory)
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	ui = {
		border = "rounded",	-- see 'border' for ':help nvim_open_win'
	},

	git = {
		log = { "-5" },
	},

	-- colorscheme that will be used when installing plugins:
	install = { colorscheme = { "gruvbox" } },

	-- automatically check for plugin updates
	checker = {
		enabled = true,
		frequency = 3600 * 24 * 50,	-- Only every 50 days
	},
})



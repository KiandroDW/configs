-- Move window mappings
local function map(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

-- Map Ctrl + arrow keys for window movement
map('n', '<C-Up>', '<C-w>k')
map('n', '<C-Down>', '<C-w>j')
map('n', '<C-Left>', '<C-w>h')
map('n', '<C-Right>', '<C-w>l')
map('i', '<C-f>', '<C-x><C-f>')

vim.keymap.set('n', '<leader>bt', function ()
	if vim.o.background == "light" then
		vim.o.background = "dark"
	else
		vim.o.background = "light"
	end
end)

-- Escape terminal mode easily
map('t', '<Esc>', [[<C-\><C-n>]])

-- Quickfix navigation
map('n', '<M-j>', '<cmd>cnext<CR>')
map('n', '<M-k>', '<cmd>cprev<CR>')

-- Special characters
map('i', '<M-i>', 'ï')
map('i', '<M-e>', 'ë')

-- For convenience
map('n', '<leader>w', '<C-w>')

-- Function defined in lua/functions.lua
map('n', '<leader>lm', ':MacroShow<CR>')

local function do_vertical()
	local hor_space = vim.api.nvim_win_get_width(0)
	local ver_space = vim.api.nvim_win_get_height(0)
	return hor_space > ver_space * 3
end

local function resize_buffer_vertical()
	local lines_in_file = vim.fn.line("$") -- last line in buffer
	vim.cmd.resize(lines_in_file)
end

local function resize_buffer_horizontal()
	local longest_line_length = 0
	local first_visible_line = vim.fn.line("w0")
	local last_visible_line = vim.fn.line("w$")
	local num_column_width = vim.opt.numberwidth:get()

	for i=first_visible_line,last_visible_line do
		local line_length = vim.fn.strdisplaywidth(vim.fn.getline(i))
		if line_length > longest_line_length then
			longest_line_length = line_length
		end
	end

	longest_line_length = longest_line_length + num_column_width + 1

	vim.cmd(string.format("vertical resize %d", longest_line_length))
end


local float_state = {
	floating = {
		buf = -1,
		win = -1,
	}
}
-- Forward declare for circular dependency
local toggle_floating_terminal

local function create_floating_window(opts)
	opts = opts or {}

	local width = opts.width or math.floor(vim.o.columns * 0.75)
	local height = opts.height or math.floor(vim.o.lines * 0.75)

	-- Calculate position
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

function toggle_floating_terminal()
	if not vim.api.nvim_win_is_valid(float_state.floating.win) then
		float_state.floating = create_floating_window({
			buf = float_state.floating.buf
		})
		if vim.bo[float_state.floating.buf].buftype ~= "terminal" then
			vim.cmd.terminal()

			-- Shift-escape as quick exit without closing buffer
			vim.keymap.set(
				't',
				"<C-q>", toggle_floating_terminal,
				{
					buffer = float_state.floating.buf,
					noremap = true, silent = true
				}
			)
		end
		vim.cmd.startinsert()
	else
		vim.api.nvim_win_hide(float_state.floating.win)
	end
end

-- Open a split terminal where it fits.
-- When there are already 2 visible windows open, it opens in a new tab,
-- otherwise it opens a split where there's the most room.
-- After opening the terminal it immediatly starts insert mode.
local function open_split_terminal()
    if #vim.api.nvim_tabpage_list_wins(0) >= 2 then
        vim.cmd("tabnew +terminal")
    elseif do_vertical() then
		vim.cmd("vsplit +terminal")
	else
		vim.cmd("split +terminal")
	end
	vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Floatty", toggle_floating_terminal, {})

local wk = require("which-key")
wk.add({
	mode = 'n',
	{ "<leader>o", group = "Open..." },
	{ "<leader>oq", vim.cmd.copen, desc = "Open quickfix list" },
	{ "<leader>ot", open_split_terminal, desc = "Open terminal where there is most space" },
	{ "<leader>of", toggle_floating_terminal, desc = "Toggle floating terminal" },

	{ "<leader>q", group = "Quickfix-list" },
	{ "<leader>qo", vim.cmd.copen, desc = "Open quickfix list" },
	{ "<leader>qc", vim.cmd.cclose, desc = "Close quickfix list" },
	{ "<leader>qn", vim.cmd.cnext, desc = "Go to next quickfix item, alias of <M-j>" },
	{ "<leader>qp", vim.cmd.cprevious, desc = "Go to previous quickfix item, alias of <M-k>" },

	{ "<leader>s", vim.cmd.write, desc = "Save file" },

	{ "<leader>rv", resize_buffer_vertical, desc = "Resize buffer to amount of rows in file" },
	{ "<leader>rh", resize_buffer_horizontal, desc = "Resize buffer to longest line in file" },
})
wk.add({
	mode = { 'n', 'v' },
	{ "<leader>y", "\"+y", desc = "Yank to global clipboard" },
	{ "<leader>p", "\"+p", desc = "Paste from global clipboard" },
})

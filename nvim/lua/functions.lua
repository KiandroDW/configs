local function gobble(lines)
	-- Taken from "michealrommel/nvim-silicon/lua/nvim-silicon/utils.lua"
	local shortest_whitespace = nil
	local whitespace = ""
	for _,v in pairs(lines) do
		_,_, whitespace = string.find(v, "^(%s*)")
		if type(whitespace) ~= "nil" then
			if shortest_whitespace == nil
				or (#whitespace < #shortest_whitespace and v ~= "") then
				shortest_whitespace = whitespace
			end
		end
	end

	if #shortest_whitespace > 0 then
		local newlines = {}
		for _,v in pairs(lines) do
			local newline = string.gsub(v, "^" .. shortest_whitespace, "", 1)
			table.insert(newlines, newline)
		end
		return newlines
	else
		return lines
	end
end

function Discord(line1, line2)
	-- Get file extension based on buffer's filetype
	local extension = vim.bo.filetype
	if extension == "c3" then
		extension = "cpp"
	end

	-- Save current register contents
	local reg_save = vim.fn.getreg('"')

	-- Get selected lines, and remove common leading whitespace
	local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
	lines = gobble(lines)
	local selected_text = table.concat(lines, "\n")

	-- Surround the text in a Markdown code-block
	local code_block = "```" .. extension .. "\n" .. selected_text .. "\n```\n"

	-- Copy code block to clipboard
	vim.fn.setreg("+", code_block)

	-- Restore original register contents
	vim.fn.setreg('"', reg_save)

	print("Copied to clipboard")
end

vim.api.nvim_create_user_command("Discord", function(opts)
	opts = opts or {}
	local line1 = opts.line1 or -1
	local line2 = opts.line2 or -1

	if line1 < 0 or line2 < 0 then
		print("Invalid range, aborting.")
		return
	end
	Discord(line1, line2)
end, { range = true })


vim.api.nvim_create_user_command("PinTop", function (opts)
	opts = opts or {}
	local line1 = opts.line1 or -1
	local line2 = opts.line2 or -1

	if line1 < 0 or line2 < 0 then
		print("Invalid range, aborting.")
		return
	end

	-- Split current buffer, and make top buffer only show the selection
	vim.cmd("topleft split")
	vim.opt_local.scrolloff = 0
	vim.opt_local.winfixheight = true
	vim.cmd.resize(line2 - line1 + 1)
	vim.cmd("normal! " .. line2 .. "G")
	vim.cmd.wincmd('j')

end, { range = true })


local function find_macro_under_cursor(bufnr)
	local word_under_cursor = vim.fn.expand("<cword>")

	local parser = vim.treesitter.get_parser(bufnr, "c")
	local tree = parser:parse()[1]
	local root = tree:root()

	local query = vim.treesitter.query.parse(vim.bo.filetype, [[
	(preproc_function_def
		name: (identifier) @macro_name
		parameters: (preproc_params)? @macro_params
		value: (_) @macro_body)

	(preproc_def
		name: (identifier) @macro_name
		value: (_) @macro_body)
	]])

	for _, match, _ in query:iter_matches(root, bufnr, 0, -1, { all = true }) do
		local match_name = match[1][1]
		local match_params = match[2] and match[2][1]
		local match_body = match[3] and match[3][1]

		if match_name and match_body then
			local name = vim.treesitter.get_node_text(match_name, bufnr)
			local body = vim.treesitter.get_node_text(match_body, bufnr)
			local params = nil
			if match_params then
				params = vim.treesitter.get_node_text(match_params, bufnr)
			end

			if name == word_under_cursor then
				-- Determine full expression
				local current_pos = vim.api.nvim_win_get_cursor(0)
				local reg_save = vim.fn.getreg('"') -- Store current register
				vim.cmd("normal! yib") -- Yank around next ()

				local filled_args = vim.fn.getreg('"')

				vim.fn.setreg('"', reg_save) -- Restore current register
				vim.api.nvim_win_set_cursor(0, current_pos) -- Restore cursor

				return {
					name = name,
					args = params,
					body = body,
					filled_args = filled_args,
				}
			end
		end
	end

	return nil
end

local function format_macro_expansion(macro)
	local result = "#define " .. macro.name

	if not macro.args then
		result = result .. " " .. macro.body
		return vim.split(result, "\n")
	end

	result = result .. macro.args .. " \\\n\t" .. macro.body
	result = result .. "\n/* Expands to: */\n"

	local filled_args = {}
	for arg in macro.filled_args:gmatch("([^, ]+)") do
		table.insert(filled_args, arg)
	end

	local body = macro.body:gsub("\\ *\n", "\n")
	local i = 1

	for arg in macro.args:match("%((.*)%)"):gmatch("([^, ]+)") do
		local stringified_pattern = "#%s*" .. arg .. "%f[%W]"
		local pattern = "%f[%w]" .. arg .. "%f[%W]"

		body = body:gsub(stringified_pattern, '"' .. filled_args[i] .. '"')
		body = body:gsub(pattern, filled_args[i])
		i = i + 1
	end

	-- Remove common indent
	body = body:gsub("\n\t", "\n")

	result = result .. body

	return vim.split(result, "\n")
end

local function show_expansion(lines)
	local longest_line_length = 0
	local amount_lines = 0
	for _, line in ipairs(lines) do
		if line:len() > longest_line_length then
			longest_line_length = line:len()
		end
		amount_lines = amount_lines + 1
	end
	longest_line_length = longest_line_length + 2
	if longest_line_length > vim.api.nvim_win_get_width(0) - 4 then
		longest_line_length = vim.api.nvim_win_get_width(0) - 4
	end
	if amount_lines > 20 then
		amount_lines = 20
	end

	local opts = {
		height = amount_lines,
		width = longest_line_length,
		border = "rounded",
		focus_id = "show_expansion",
	}

	local b, _ = vim.lsp.util.open_floating_preview(lines, '', opts)
	vim.bo[b].filetype = vim.bo.filetype
end

vim.api.nvim_create_user_command("MacroShow", function()
	local supported_langs = {}
	supported_langs["c"] = true
	supported_langs["cpp"] = true

	if not supported_langs[vim.bo.filetype] then
		return
	end

	local macro = find_macro_under_cursor(0)
	if macro then
		local formatted = format_macro_expansion(macro)
		show_expansion(formatted)
	end
end, {})

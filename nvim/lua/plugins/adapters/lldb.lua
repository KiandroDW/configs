-- lldb for C/C++ (and Rust)
local dap = require("dap")

dap.adapters.codelldb = function(on_adapter)
	-- This asks the system for a free port
	local tcp = vim.loop.new_tcp()
	tcp:bind('127.0.0.1', 0)
	local port = tcp:getsockname().port
	tcp:shutdown()
	tcp:close()

	-- Ask the user for the file

	-- Start codelldb with the port
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)
	local opts = {
		stdio = {nil, stdout, stderr},
		args = {'--port', tostring(port)},
	}
	local handle
	local pid_or_err
	-- Assumes that codelldb was installed using mason
	handle, pid_or_err = vim.loop.spawn(os.getenv("HOME") .. '/.local/share/nvim/mason/bin/codelldb', opts, function(code)
		stdout:close()
		stderr:close()
		handle:close()
		if code ~= 0 then
			print("codelldb exited with code", code)
		end
	end)
	if not handle then
		vim.notify("Error running codelldb: " .. tostring(pid_or_err), vim.log.levels.ERROR)
		stdout:close()
		stderr:close()
		return
	end
	vim.notify('codelldb started. pid=' .. pid_or_err)
	stderr:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			vim.schedule(function()
				require("dap.repl").append(chunk)
			end)
		end
	end)
	local adapter = {
		type = 'server',
		host = '127.0.0.1',
		port = port
	}
	-- Wait for codelldb to get ready and start listening before telling nvim-dap to connect
	-- If you get connect errors, try to increase 500 to a higher value, or check the stderr (Open the REPL)
	vim.defer_fn(function() on_adapter(adapter) end, 1000)
end

-- Utility function to show a list of items and wait for the user to choose
-- before continuing
local function pick_one(items, prompt, label_fn, cb)
	local co
	if not cb then
		co = coroutine.running()
		if co then
			cb = function(item)
				coroutine.resume(co, item)
			end
		end
	end
	cb = vim.schedule_wrap(cb)
	vim.ui.select(items, {
		prompt = prompt,
		format_item = label_fn,
	}, cb)
	if co then
		return coroutine.yield()
	end
end

-- Utility function to ask the user for some input in a floating window
local function get_input(_prompt)
	local co, cb
	co = coroutine.running()
	if co then
		cb = function(input)
			coroutine.resume(co, input)
		end
	end
	cb = vim.schedule_wrap(cb)

	-- nui for the floating window
	local _input = require("nui.input")
	local input = _input(
		{
			position = "50%",
			border = { style = "rounded" },
			size = { width = 40 }
		}, {
			prompt = _prompt,
			on_close = function() cb("") end,
			on_submit = function(value) cb(value) end,
		}
	)
	input:mount()

	if co then
		return coroutine.yield()
	end
end

-- Ask the user to select an executable from the list `find` (bash) finds
local function select_debug_executable()
	local exes = {}
	local files = io.popen("find -type f -executable -not -path '*/.git/*'")
	if files then
		for file in files:lines() do
			table.insert(exes, file)
		end
		files:close()
	end

	if not files or #exes == 0 then
		return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
	end

	local path = pick_one(exes, "Pick debug executable: ")
	return path
end

-- don't forget to compile/build with debug symbols, otherwise it won't work.
dap.configurations.cpp = {
	{
		name = "runit",
		type = "codelldb",
		request = "launch",

		program = function()
			return select_debug_executable()
		end,

		args = function()
			local args_list = {}
			local extra_inputs = get_input("Program args: ")
			for _, e in ipairs(vim.split(extra_inputs, " ")) do
				table.insert(args_list, e)
			end
			return args_list
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		terminal = 'integrated',
		runInTerminal = true,

		pid = function()
			local handle = io.popen('pgrep hw$')
			if handle ~= nil then
				local result = handle:read()
				handle:close()
				return result
			end
		end
	},
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.h = dap.configurations.cpp
dap.configurations.c3 = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

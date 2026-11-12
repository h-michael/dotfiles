-- Telescope picker for the other Neovim instances on this machine, modeled
-- on fzf-lua's `:FzfLua serverlist`.
--
-- Every Neovim listens on a socket under stdpath("run")/.. by default. Each
-- socket is probed with `nvim --server ADDR --remote-expr` in a separate
-- process, so an instance that does not answer (busy, or a stale socket
-- left by a crash) only costs the timeout instead of blocking this UI.
-- <CR> moves this UI to the selected instance with :connect; the instance
-- left behind keeps running without a UI and stays in this list.
local M = {}

local PROBE_TIMEOUT_MS = 500

-- Lua evaluated inside the target instance. It is wrapped in a one-line
-- Vimscript luaeval("..."), so it must not contain double quotes.
local PROBE_LUA = table.concat({
	"vim.json.encode({",
	"cwd = vim.uv.cwd(),",
	"rss_kb = vim.uv.getrusage().maxrss,",
	"bufs = vim.tbl_map(vim.api.nvim_buf_get_name, vim.tbl_filter(function(b)",
	"return vim.bo[b].buflisted and vim.api.nvim_buf_get_name(b) ~= ''",
	"end, vim.api.nvim_list_bufs())),",
	"})",
}, " ")
local PROBE_EXPR = 'luaeval("' .. PROBE_LUA .. '")'

local function scan_sockets()
	local root = vim.fs.normalize(vim.fn.stdpath("run") .. "/..")
	return vim.fs.find(function(name)
		return name:match("^nvim") ~= nil
	end, { path = root, type = "socket", limit = math.huge })
end

local function probe_all(addrs)
	local jobs = {}
	for _, addr in ipairs(addrs) do
		jobs[#jobs + 1] = {
			addr = addr,
			proc = vim.system({ vim.v.progpath, "--server", addr, "--remote-expr", PROBE_EXPR }, { text = true }),
		}
	end

	-- One deadline shared by all probes, since they run in parallel
	local deadline = vim.uv.hrtime() / 1e6 + PROBE_TIMEOUT_MS
	local instances = {}
	for _, job in ipairs(jobs) do
		local remaining = math.max(math.floor(deadline - vim.uv.hrtime() / 1e6), 1)
		local res = job.proc:wait(remaining)
		if res.code == 0 then
			local ok, info = pcall(vim.json.decode, res.stdout)
			if ok and type(info) == "table" and info.cwd then
				info.addr = job.addr
				instances[#instances + 1] = info
			end
		end
	end
	table.sort(instances, function(a, b)
		return a.cwd < b.cwd
	end)
	return instances
end

local function display(inst, cwd_width)
	return string.format(
		"%-" .. cwd_width .. "s  %5.0fM  %d buf%s",
		vim.fn.fnamemodify(inst.cwd, ":~"),
		(inst.rss_kb or 0) / 1024,
		#inst.bufs,
		#inst.bufs == 1 and "" or "s"
	)
end

---Other responsive Neovim instances, sorted by working directory
---@return { addr: string, cwd: string, rss_kb: integer?, bufs: string[] }[]
function M.list()
	local own = {}
	for _, addr in ipairs(vim.fn.serverlist()) do
		own[addr] = true
	end
	local addrs = vim.tbl_filter(function(addr)
		return not own[addr]
	end, scan_sockets())
	return probe_all(addrs)
end

function M.pick(opts)
	local instances = M.list()
	if #instances == 0 then
		vim.notify("No other Neovim instances found", vim.log.levels.INFO)
		return
	end

	local cwd_width = 0
	for _, inst in ipairs(instances) do
		cwd_width = math.max(cwd_width, vim.fn.strdisplaywidth(vim.fn.fnamemodify(inst.cwd, ":~")))
	end
	cwd_width = math.min(cwd_width, 60)

	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")
	local previewers = require("telescope.previewers")
	local conf = require("telescope.config").values

	pickers
		.new(opts or {}, {
			prompt_title = "Neovim instances",
			finder = finders.new_table({
				results = instances,
				entry_maker = function(inst)
					return {
						value = inst,
						display = display(inst, cwd_width),
						-- Match on open file names as well as the directory
						ordinal = inst.cwd .. " " .. table.concat(inst.bufs, " "),
					}
				end,
			}),
			sorter = conf.generic_sorter(opts or {}),
			previewer = previewers.new_buffer_previewer({
				title = "Open buffers",
				define_preview = function(self, entry)
					local lines = { entry.value.addr, "" }
					for _, name in ipairs(entry.value.bufs) do
						lines[#lines + 1] = vim.fn.fnamemodify(name, ":~")
					end
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
				end,
			}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if not entry then
						return
					end
					local addr = entry.value.addr
					-- :connect detaches this UI first, so never connect to an
					-- instance that exited after the list was built.
					local ok, chan = pcall(vim.fn.sockconnect, "pipe", addr, { rpc = true })
					if not ok or chan == 0 then
						vim.notify("Neovim instance is gone: " .. addr, vim.log.levels.WARN)
						return
					end
					vim.fn.chanclose(chan)
					vim.cmd.connect(addr)
				end)
				return true
			end,
		})
		:find()
end

return M

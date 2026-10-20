-- lazygit in a floating terminal that survives being closed.
--
-- lazygit.nvim kills lazygit every time its float goes away, so each
-- <leader>lg starts over at the top of the files panel. Here closing the float
-- only hides the window: the terminal buffer and the lazygit process stay
-- alive, and the next <leader>lg puts the same session back on screen with the
-- same panel, selection and scroll position.
--
-- lazygit's 'o' (see `os.open` in lazygit's config.yml) calls
-- LazygitOpenInTab over RPC. That hides the float and opens the file, leaving
-- lazygit running so you come back to the file you opened from.

local buf = -1
local win = -1
local prev_win = -1
local job_cwd

local function float_config()
	local width = math.ceil(vim.o.columns * 0.9)
	local height = math.ceil(vim.o.lines * 0.9) - 1
	return {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
	}
end

local function is_running()
	return vim.api.nvim_buf_is_valid(buf) and vim.b[buf].terminal_job_id ~= nil
		and vim.fn.jobwait({ vim.b[buf].terminal_job_id }, 0)[1] == -1
end

local function hide()
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	win = -1
	if vim.api.nvim_win_is_valid(prev_win) then
		vim.api.nvim_set_current_win(prev_win)
	end
	-- lazygit may have staged, checked out or discarded changes.
	vim.cmd("silent! checktime")
end

local function open()
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
		vim.cmd("startinsert")
		return
	end

	-- A session started in another directory is looking at another repo.
	if is_running() and job_cwd ~= vim.fn.getcwd() then
		vim.fn.jobstop(vim.b[buf].terminal_job_id)
		vim.api.nvim_buf_delete(buf, { force = true })
	end

	prev_win = vim.api.nvim_get_current_win()

	if is_running() then
		win = vim.api.nvim_open_win(buf, true, float_config())
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].filetype = "lazygit"
		win = vim.api.nvim_open_win(buf, true, float_config())
		job_cwd = vim.fn.getcwd()
		local this_buf = buf
		vim.fn.jobstart({ "lazygit" }, {
			term = true,
			on_exit = function()
				-- Quitting lazygit with 'q' really ends the session.
				if buf == this_buf then
					hide()
					buf = -1
				end
				if vim.api.nvim_buf_is_valid(this_buf) then
					vim.api.nvim_buf_delete(this_buf, { force = true })
				end
			end,
		})
	end

	-- `style = "minimal"` only holds for the first window: re-showing a hidden
	-- buffer restores the window options it last had, so 'signcolumn' comes
	-- back as "auto". A sign column then eats two columns of the terminal and
	-- the view scrolls sideways, clipping lazygit's left edge. Reapply them and
	-- scroll back to the first column.
	local wo = vim.wo[win]
	wo.number = false
	wo.relativenumber = false
	wo.signcolumn = "no"
	wo.foldcolumn = "0"
	wo.statuscolumn = ""
	wo.wrap = false
	wo.sidescrolloff = 0
	wo.winhl = "NormalFloat:Normal,FloatBorder:Normal"
	vim.fn.winrestview({ leftcol = 0 })
	vim.cmd("startinsert")
end

function _G.LazygitOpenInTab(file)
	vim.schedule(function()
		hide()
		-- `tab drop` jumps to an existing window for the file if there is one,
		-- and only opens a new tab otherwise.
		vim.cmd("tab drop " .. vim.fn.fnameescape(file))
	end)
	return ""
end

vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_config(win, float_config())
		end
	end,
})

vim.keymap.set("n", "<leader>lg", open, { desc = "LazyGit" })

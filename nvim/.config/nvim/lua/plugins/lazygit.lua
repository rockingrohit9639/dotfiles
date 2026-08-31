return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	},
	config = function()
		-- lazygit's 'o' (open) keybinding calls back into this Neovim over RPC
		-- (see the `os.open` command in lazygit's config.yml). Opening the file
		-- there and then doesn't stick: lazygit.nvim's on_exit handler ends with
		-- nvim_set_current_win(prev_win), which drags focus back to whatever
		-- window was current before the float opened. So 'o' only records the
		-- file, and we open it from on_exit's callback, which runs last.
		local pending_file

		function _G.LazygitOpenInTab(file)
			pending_file = file
			return ""
		end

		vim.g.lazygit_on_exit_callback = function()
			local file = pending_file
			pending_file = nil
			if file == nil or file == "" then
				return
			end
			vim.schedule(function()
				-- `tab drop` jumps to an existing window for the file if there is
				-- one, and only opens a new tab otherwise.
				vim.cmd("tab drop " .. vim.fn.fnameescape(file))
			end)
		end
	end,
}

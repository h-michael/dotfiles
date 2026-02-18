return {
	{
		"rhysd/rust-doc.vim",
		ft = { "help" },
	},
	{
		"saecki/crates.nvim",
		tag = "stable",
		event = "BufRead Cargo.toml",
		config = function()
			require("crates").setup()
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
			map_cr = true,
		},
	},
	{ "bfredl/nvim-luadev" },
	--  Plugin for vim to enabling opening a file in a given line
	{ "bogado/file-line" },
	-- Vim and Neovim plugin to reveal the commit messages under the cursor
	{
		"rhysd/git-messenger.vim",
		cmd = { "GitMessenger", "GitMessengerClose" },
	},
	-- Edit vinari
	{
		"Shougo/vinarise.vim",
		cmd = { "Vinarise" },
	},
	-- endwise.vim: wisely add "end" in ruby, endfunction/endif/more in vim script, etc
	{
		"tpope/vim-endwise",
		ft = { "ruby" },
	},
	-- simple memo plugin for Vim.
	{
		"glidenote/memolist.vim",
		cmd = { "MemoNew", "MemoList", "MemoGrep" },
	},
	-- Open GitHub URL of current file, etc. from Vim editor (supported GitHub Enterprise)
	{
		"tyru/open-browser-github.vim",
		dependencies = { "tyru/open-browser.vim" },
		cmd = { "OpenGithubFile", "OpenGithubIssue", "OpenGithubPullReq" },
	},
	{
		"github/copilot.vim",
		enabled = true,
		init = function()
			vim.g.copilot_command = "copilot-language-server"
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "<C-h>", "<cmd>WhichKey<CR>", mode = "n", desc = "WhichKey" }, -- stylua: ignore
		},
	},
}

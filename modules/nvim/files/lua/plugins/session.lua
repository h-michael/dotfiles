return {
	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			-- Save session on exit, restore on entering same directory
			auto_save = true,
			auto_restore = true,
			-- Don't create sessions for these directories
			suppressed_dirs = { "~/", "~/Downloads", "/tmp" },
			-- Telescope integration
			session_lens = {
				load_on_setup = true,
				previewer = false,
			},
		},
		keys = {
			{ "<leader>ss", "<cmd>SessionSave<cr>", desc = "Save session" },
			{ "<leader>sr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
			{ "<leader>sd", "<cmd>SessionDelete<cr>", desc = "Delete session" },
			{ "<leader>sl", "<cmd>SessionSearch<cr>", desc = "Search sessions" },
		},
	},
}

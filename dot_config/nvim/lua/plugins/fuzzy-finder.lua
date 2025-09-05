return {
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				defaults = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "top",
						},
						vertical = {
							prompt_position = "top",
						},
					},
					sorting_strategy = "ascending",
					mappings = {
						i = {
							["<Esc>"] = require("telescope.actions").close,
							["<C-h>"] = "which_key",
						},
						n = {
							["Esc"] = require("telescope.actions").close,
							["<C-h>"] = "which_key",
						},
					},
					vimgrep_arguments = {
						"rg",
						"--color=always",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
					},
				},
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			})
			telescope.load_extension("fzf")

			local wk = require("which-key")

			wk.add({
				{ "<Leader>f", group = "Telescope", remap = false },
				{
					"<Leader>f/",
					function()
						builtin.current_buffer_fuzzy_find({ previewer = false })
					end,
					desc = "Fuzzy find in buffer",
					remap = false,
				},
				{
					"<Leader>fb",
					function()
						builtin.buffers()
					end,
					desc = "Switch buffer",
					remap = false,
				},
				{
					"<Leader>fcd",
					function()
						builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
					end,
					desc = "Find file in buffer's directory",
					remap = false,
				},
				{
					"<Leader>fw",
					function()
						builtin.grep_string()
					end,
					desc = "Grep string under cursor",
					remap = false,
				},
				{
					"<Leader>ff",
					function()
						builtin.find_files()
					end,
					desc = "Find file",
					remap = false,
				},
				{
					"<Leader>fpf",
					function()
						builtin.find_files({ cwd = vim.fn.getcwd() })
					end,
					desc = "Find file in project root",
					remap = false,
				},
				{
					"<Leader>frg",
					function()
						builtin.live_grep()
					end,
					desc = "Live grep project",
					remap = false,
				},
				{
					"<Leader>ft",
					function()
						builtin.tags()
					end,
					desc = "Find tag",
					remap = false,
				},
			})
		end,
	},
	{
		"ibhagwan/fzf-lua",
		enabled = false,
		config = function()
			require("fzf-lua").register_ui_select()

			local api = vim.api
			api.nvim_create_user_command("Rg", function(_opts)
				require("fzf-lua").grep({
					rg_opts = "--column --line-number --no-heading --color=always --smart-case",
				})
			end, { bang = true, nargs = "*" })
			api.nvim_create_user_command("CurrentWordRg", function(_opts)
				require("fzf-lua").grep({
					rg_opts = "--column --line-number --no-heading --color=always --smart-case",
				})
			end, { bang = true, nargs = "*" })
			api.nvim_create_user_command("CurrentBufferDir", function(_opts)
				require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") })
			end, { bang = true, nargs = "?" })
			api.nvim_create_user_command("ProjectDir", function(_opts)
				require("fzf-lua").files({ cwd = vim.fn.getcwd() })
			end, { bang = true, nargs = "?" })
			local opt = { noremap = true, silent = true }
			vim.api.nvim_set_keymap(
				"n",
				"/",
				"<cmd>lua require('fzf-lua').blines({ winopts = { preview = { hidden = 'hidden' } } })<CR>",
				opt
			)
			vim.api.nvim_set_keymap("n", "<Leader>cw", "<cmd>lua require('fzf-lua').grep_cword()<CR>", opt)
			vim.api.nvim_set_keymap("n", "<Leader>cbd", ":CurrentBufferDir <CR>", opt)
			vim.api.nvim_set_keymap("n", "<Leader>pd", ":ProjectDir <CR>", opt)
			vim.api.nvim_set_keymap("n", "<Leader>rg", ":Rg <CR>", opt)
			vim.api.nvim_set_keymap("n", "<Leader>gr", ":Rg <CR>", opt)
			vim.api.nvim_set_keymap("n", "<Leader>b", "<cmd>lua require('fzf-lua').buffers()<CR>", opt)
			vim.api.nvim_set_keymap("n", "<Leader>f", "<cmd>lua require('fzf-lua').files()<CR>", opt)
			vim.api.nvim_set_keymap("n", "<Leader>t", "<cmd>lua require('fzf-lua').tags()<CR>", opt)
		end,
	},
}

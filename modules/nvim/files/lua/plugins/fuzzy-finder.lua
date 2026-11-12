return {
	-- Loaded as telescope's dependency
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		-- Loaded on first use instead of at startup. The <Leader>f group label
		-- is registered in which-key's opts (plugins/plugin.lua).
		cmd = "Telescope",
		-- stylua: ignore start
		keys = {
			{ '<Leader>f/', function() require('telescope.builtin').current_buffer_fuzzy_find({ previewer = false }) end, desc = 'Fuzzy find in buffer' },
			{ '<Leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Switch buffer' },
			{ '<Leader>fcd', function() require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h') }) end, desc = "Find file in buffer's directory" },
			{ '<Leader>fw', function() require('telescope.builtin').grep_string() end, desc = 'Grep string under cursor' },
			{ '<Leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find file' },
			{ '<Leader>fpf', function() require('telescope.builtin').find_files({ cwd = vim.fn.getcwd() }) end, desc = 'Find file in project root' },
			{ '<Leader>frg', function() require('telescope.builtin').live_grep() end, desc = 'Live grep project' },
			{ '<Leader>ft', function() require('telescope.builtin').tags() end, desc = 'Find tag' },
		},
		-- stylua: ignore end
		config = function()
			local telescope = require("telescope")

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
							["<Esc>"] = require("telescope.actions").close,
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
		end,
	},
}

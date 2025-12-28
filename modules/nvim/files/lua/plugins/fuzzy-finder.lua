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

      -- stylua: ignore start
      wk.add({
        { '<Leader>f', group = 'Telescope' },
        { '<Leader>f/', function() builtin.current_buffer_fuzzy_find({ previewer = false }) end, desc = 'Fuzzy find in buffer' },
        { '<Leader>fb', function() builtin.buffers() end, desc = 'Switch buffer' },
        { '<Leader>fcd', function() builtin.find_files({ cwd = vim.fn.expand('%:p:h') }) end, desc = "Find file in buffer's directory" },
        { '<Leader>fw', function() builtin.grep_string() end, desc = 'Grep string under cursor' },
        { '<Leader>ff', function() builtin.find_files() end, desc = 'Find file' },
        { '<Leader>fpf', function() builtin.find_files({ cwd = vim.fn.getcwd() }) end, desc = 'Find file in project root' },
        { '<Leader>frg', function() builtin.live_grep() end, desc = 'Live grep project' },
        { '<Leader>ft', function() builtin.tags() end, desc = 'Find tag' },
      })
			-- stylua: ignore end
		end,
	},
	{
		"ibhagwan/fzf-lua",
		enabled = false,
		config = function()
			local fzf_lua = require("fzf-lua")
			fzf_lua.register_ui_select()

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
      -- stylua: ignore start
      vim.api.nvim_set_keymap('n', '/', function() fzf_lua.blines({ winopts = { preview = { hidden = 'hidden' } } }) end, opt)
      vim.api.nvim_set_keymap('n', '<Leader>cw', function() fzf_lua.grep_cword() end, opt)
      vim.api.nvim_set_keymap('n', '<Leader>cbd', ':CurrentBufferDir <CR>', opt)
      vim.api.nvim_set_keymap('n', '<Leader>pd', ':ProjectDir <CR>', opt)
      vim.api.nvim_set_keymap('n', '<Leader>rg', ':Rg <CR>', opt)
      vim.api.nvim_set_keymap('n', '<Leader>gr', ':Rg <CR>', opt)
      vim.api.nvim_set_keymap('n', '<Leader>b', function() fzf_lua.buffers() end, opt)
      vim.api.nvim_set_keymap('n', '<Leader>f', function() fzf_lua.files() end, opt)
      vim.api.nvim_set_keymap('n', '<Leader>t', function() fzf_lua.tags() end, opt)
			-- stylua: ignore end
		end,
	},
}

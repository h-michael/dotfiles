return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night",
				on_highlights = function(hl, c)
					hl.WinSeparator = {
						fg = c.yellow,
					}
				end,
			})
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
	},
	{
		"Mofiqul/dracula.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"nvim-lualine/lualine.nvim",
		event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
		config = function()
			-- CodeCompanion spinner component
			local codecompanion_spinner = require("lualine.component"):extend()

			codecompanion_spinner.processing = false
			codecompanion_spinner.spinner_index = 1

			local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
			local spinner_symbols_len = 10

			-- Initializer
			function codecompanion_spinner:init(options)
				codecompanion_spinner.super.init(self, options)

				local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

				vim.api.nvim_create_autocmd({ "User" }, {
					pattern = "CodeCompanionRequest*",
					group = group,
					callback = function(request)
						if request.match == "CodeCompanionRequestStarted" then
							self.processing = true
						elseif request.match == "CodeCompanionRequestFinished" then
							self.processing = false
						end
					end,
				})
			end

			-- Function that runs every time statusline is updated
			function codecompanion_spinner:update_status()
				if self.processing then
					self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
					return spinner_symbols[self.spinner_index]
				else
					return nil
				end
			end

			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					component_separators = { left = " ", right = " " },
					section_separators = { left = " ", right = " " },
					padding = 0,
					disabled_filetypes = {
						statusline = {},
						winbar = {},
					},
					always_divide_middle = true,
					globalstatus = true,
					refresh = {
						statusline = 100, -- Faster refresh for smooth spinner animation
						tabline = 1000,
						winbar = 1000,
					},
					path = 4,
				},
				sections = {
					lualine_a = {
						{
							"mode",
							fmt = function(str)
								return " " .. str:sub(1, 1) .. " "
							end,
						},
					},
					lualine_b = { "branch" },
					lualine_c = { "filename" },
					lualine_x = { codecompanion_spinner, "diagnostics" }, -- CodeCompanion processing spinner
					lualine_y = { "encoding", "fileformat", "filetype" },
					lualine_z = { "progress", "location" },
				},
				inactive_sections = {
					lualine_a = { "filename" },
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {},
			})
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
	},
	{
		"nvim-mini/mini.icons",
		version = false,
	},
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = {
			filetypes = {
				"html",
				"css",
				"javascript",
				"typescript",
				"lua",
				"tmux",
				"sh",
				"bash",
				"zsh",
				"fish",
			},
		},
	},
	{
		"uga-rosa/ccc.nvim",
		cmd = {
			"CccPick",
			"CccConvert",
			"CccHighlighterToggle",
			"CccHighlighterEnable",
			"CccHighlighterDisable",
		},
	},
}

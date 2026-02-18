return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master", -- Pin to master for compatibility with textobjects etc.
		build = ":TSUpdate",
		event = "VimEnter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"c",
					"cmake",
					"cpp",
					"css",
					"csv",
					"diff",
					"dockerfile",
					"fish",
					"git_config",
					"git_rebase",
					"gitattributes",
					"gitcommit",
					"gitignore",
					"go",
					"gomod",
					"gosum",
					"gotmpl",
					"haskell",
					"html",
					"hyprlang",
					"ini",
					"java",
					"javascript",
					"json",
					"json5",
					"jsonnet",
					"lua",
					"luadoc",
					"make",
					"markdown",
					"markdown_inline",
					"mermaid",
					"nginx",
					"nix",
					"ocaml",
					"perl",
					"php",
					"proto",
					"python",
					"regex",
					"ruby",
					"rust",
					"scss",
					"sql",
					"ssh_config",
					"terraform",
					"tmux",
					"toml",
					"tsv",
					"tsx",
					"typescript",
					"vim",
					"yaml",
				},
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("treesitter-context").setup({
				enable = false,
			})
			vim.api.nvim_set_keymap(
				"n",
				"<Leader>gc",
				'<cmd>lua require("treesitter-context").go_to_context(vim.v.count1)<CR>',
				{ noremap = true, silent = true }
			)
		end,
	},
}

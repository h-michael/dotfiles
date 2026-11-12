return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({})

			-- No tmux: nvim-treesitter dropped it (78bebef1) after upstream
			-- stopped committing generated files to its default branch.
			-- tmux.conf falls back to Neovim's syntax/tmux.vim.
			require("nvim-treesitter").install({
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
				"toml",
				"tsv",
				"tsx",
				"typescript",
				"vim",
				"yaml",
			})

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		-- The context window is disabled; load only for the jump mapping or
		-- an explicit :TSContext.
		cmd = "TSContext",
		keys = {
			{
				"<Leader>gc",
				function()
					require("treesitter-context").go_to_context(vim.v.count1)
				end,
				silent = true,
				desc = "Go to context",
			},
		},
		opts = {
			enable = false,
		},
	},
}

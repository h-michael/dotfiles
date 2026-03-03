return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({})

			require("nvim-treesitter").install({
				"bash", "c", "cmake", "cpp", "css", "csv", "diff",
				"dockerfile", "fish", "git_config", "git_rebase",
				"gitattributes", "gitcommit", "gitignore", "go", "gomod",
				"gosum", "gotmpl", "haskell", "html", "hyprlang", "ini",
				"java", "javascript", "json", "json5", "jsonnet", "lua",
				"luadoc", "make", "markdown", "markdown_inline", "mermaid",
				"nginx", "nix", "ocaml", "perl", "php", "proto", "python",
				"regex", "ruby", "rust", "scss", "sql", "ssh_config",
				"terraform", "tmux", "toml", "tsv", "tsx", "typescript",
				"vim", "yaml",
			})

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
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

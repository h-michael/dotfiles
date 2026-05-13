return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
		keys = {
			{ "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "render-markdown toggle" },
		},
	},
	{
		"delphinus/md-render.nvim",
		version = "*",
		ft = "markdown",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			{ "delphinus/budoux.lua", version = "*" },
		},
		keys = {
			{ "<leader>mp", "<Plug>(md-render-preview)", desc = "md-render preview (toggle)" },
			{ "<leader>mt", "<Plug>(md-render-preview-tab)", desc = "md-render preview in tab (toggle)" },
			{ "<leader>ms", "<Plug>(md-render-split)", desc = "md-render source/render split" },
			{ "<leader>md", "<Plug>(md-render-demo)", desc = "md-render demo" },
		},
	},
}

return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
      -- stylua: ignore start
      { '<Leader>fmt', function() require('conform').format({ async = true, lsp_format = "fallback" }) end, mode = '', desc = 'Format buffer' },
			-- stylua: ignore end
		},
		opts = {
			formatters_by_ft = {
				-- Alternatives, not a pipeline: use whichever is available first
				javascript = { "biome", "prettier", stop_after_first = true },
				typescript = { "biome", "prettier", stop_after_first = true },
				javascriptreact = { "biome", "prettier", stop_after_first = true },
				typescriptreact = { "biome", "prettier", stop_after_first = true },
				json = { "biome", "prettier", stop_after_first = true },
				jsonc = { "biome", "prettier", stop_after_first = true },

				css = { "prettier" },
				html = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },

				c = { "clang-format" },
				cpp = { "clang-format" },
				objc = { "clang-format" },
				objcpp = { "clang-format" },
				cuda = { "clang-format" },

				terraform = { "terraform_fmt" },
				tf = { "terraform_fmt" },
				["terraform-vars"] = { "terraform_fmt" },

				rust = { "rustfmt" },
				go = { "gofmt", "goimports" },
				lua = { "stylua" },
				python = { "black", "isort" },
				proto = { "buf" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				fish = { "fish_indent" },
				toml = { "taplo" },
			},
			--format_after_save = function(bufnr)
			--  -- Disable with a global or buffer-local variable
			--  if vim.g._conform_disable_autoformat or vim.b[bufnr]._conform_disable_autoformat then
			--    return
			--  end
			--  -- Only format on save for specific filetypes
			--  local enable_filetypes = {
			--    rust = true,
			--    go = true,
			--  }
			--  local filetype = vim.bo[bufnr].filetype
			--  if enable_filetypes[filetype] then
			--    return {
			--      timeout_ms = 500,
			--      lsp_fallback = true,
			--    }
			--  end
			--  -- Don't format after save for other filetypes
			--  return nil
			--end,
		},
		--init = function()
		--  -- Format after save can be disabled with:
		--  vim.g._conform_disable_autoformat = false
		--  vim.b._conform_disable_autoformat = false

		--  vim.api.nvim_create_user_command("AutoFormatDisable", function(args)
		--    if args.bang then
		--      -- FormatDisable! will disable formatting just for this buffer
		--      vim.b._conform_disable_autoformat = true
		--    else
		--      vim.g._conform_disable_autoformat = true
		--    end
		--  end, {
		--    desc = "Disable autoformat-after-save",
		--    bang = true,
		--  })

		--  vim.api.nvim_create_user_command("AutoFormatEnable", function()
		--    vim.b._conform_disable_autoformat = false
		--    vim.g._conform_disable_autoformat = false
		--  end, {
		--    desc = "Re-enable autoformat-afrter-save",
		--  })
		--end,
	},
}

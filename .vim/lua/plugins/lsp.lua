return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local on_attach = function(_client, bufnr)
        local opts = { noremap = true, silent = true }
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })

        vim.api.nvim_set_keymap('n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<Leader>gde', '<cmd>lua vim.lsp.buf.declaration()', opts)
        vim.api.nvim_set_keymap('n', '<Leader>gdc', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<Leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<Leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<Leader>grf', '<cmd>lua vim.lsp.buf.references({ includeDeclaration = true })<CR>', opts)
        vim.api.nvim_set_keymap('n', '<Leader>fmt', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
        vim.api.nvim_set_keymap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<Leader>od', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        -- vim.api.nvim_set_keymap('n', '<Leader>gdh', '<cmd>lua vim.lsp.buf.document_highlight()<CR>', opts)
      end

      local lsp_flags = {
        debounce_text_changes = 150,
      }

      require('lspconfig')['clangd'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        capabilities = capabilities,
        cmd = {"clangd", "--background-index"},
      }
      require'lspconfig'.rust_analyzer.setup{
        cmd = { "rust-analyzer", "--verbose" },
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = vim.tbl_deep_extend(
          'force',
          require('cmp_nvim_lsp').default_capabilities(),
          {
            snippetTextEdit = true,
            codeActionGroup = true,
            hoverActions = true,
            serverStatusNotification = true,
          }
        ),
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              buildScripts = {
                enable = true,
              },
              targetDir = "target/rust_analyzer",
              features = "all",
            },
            check = {
              command = "clippy",
            },
          },
        },
      }
      require('lspconfig')['gopls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      --require('lspconfig')['solargraph'].setup{
      --  on_attach = on_attach,
      --  flags = lsp_flags,
      --  capabilities = capabilities,
      --}
      require('lspconfig')['ts_ls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      require('lspconfig')['pyright'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      require('lspconfig')['jsonls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      require('lspconfig')['yamlls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
        settings = {
          yaml = {
            format = {
              enable = true,
            },
            schemaStore = {
              enable = true,
            },
            schemas = {
              ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*.{yml,yaml}',
              ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
              ['http://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/*.{yml,yaml}',
              ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
              ['http://json.schemastore.org/stylelintrc'] = '.stylelintrc.{yml,yaml}',
              ['http://json.schemastore.org/circleciconfig'] = '.circleci/**/*.{yml,yaml}',
              ['https://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
              ['https://json.schemastore.org/cloudbuild'] = '*cloudbuild.{yml,yaml}',
              ['https://taskfile.dev/schema.json'] = '**/{Taskfile,taskfile}.{yml,yaml}',
              ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '**/*.docker-compose.{yml,yaml}',
              ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/refs/tags/3.1.1/schemas/v3.1/schema.yaml'] = '**/openapi.{yml,yaml}',
              ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/refs/tags/3.1.1/schemas/v3.0/schema.yaml'] = '**/openapi.{yml,yaml}',
              ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/refs/tags/3.1.1/schemas/v2.0/schema.json'] = '**/openapi.{yml,yaml}',
            }
          }
        },
      }
      require('lspconfig')['terraformls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      require('lspconfig')['buf_ls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      require('lspconfig')['lua_ls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
    end,
  },
}

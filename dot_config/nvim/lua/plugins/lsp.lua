return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'b0o/SchemaStore.nvim',
    },
    config = function()
      vim.lsp.set_log_level("warn")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local on_attach = function(_client, bufnr)
        local wk = require("which-key")
        wk.add({
          { "<Leader>l", buffer = bufnr, group = "LSP", remap = false },
          { "<Leader>lrn", "<cmd>lua vim.lsp.buf.rename()<CR>", buffer = bufnr, desc = "Rename", remap = false },
          { "<Leader>lds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", buffer = bufnr, desc = "Document Symbols", remap = false },
          { "<Leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", buffer = bufnr, desc = "Code Action", remap = false },
          { "<Leader>ld", "<cmd>lua vim.lsp.buf.definition()<CR>", buffer = bufnr, desc = "Go to Definition", remap = false },
          { "<Leader>le", "<cmd>lua vim.diagnostic.open_float()<CR>", buffer = bufnr, desc = "Show Diagnostic", remap = false },
          { "<Leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", buffer = bufnr, desc = "Format", remap = false },
          { "<Leader>lh", "<cmd>lua vim.lsp.buf.hover()<CR>", buffer = bufnr, desc = "Hover", remap = false },
          { "<Leader>li", "<cmd>lua vim.lsp.buf.implementation()<CR>", buffer = bufnr, desc = "Go to Implementation", remap = false },
          { "<Leader>lrf", "<cmd>lua vim.lsp.buf.references()<CR>", buffer = bufnr, desc = "References", remap = false },
          { "<Leader>lsig", "<cmd>lua vim.lsp.buf.signature_help()<CR>", buffer = bufnr, desc = "Signature Help", remap = false },
          { "<Leader>lt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", buffer = bufnr, desc = "Type Definition", remap = false }
        })

        --local opts = { noremap = true, silent = true }

        --vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
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
            },
            check = {
              command = "clippy",
              extraArgs = {
                "--all-targets",
                "--all-features",
              },
              --command = "check",
              --extraArgs = {
              --  "--target-dir=target/rust_analyzer",
              --},
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
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          }
        }
      }
      require('lspconfig')['yamlls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
            --schemas = {
            --  ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*.{yml,yaml}',
            --  ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
            --  ['http://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/*.{yml,yaml}',
            --  ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
            --  ['http://json.schemastore.org/stylelintrc'] = '.stylelintrc.{yml,yaml}',
            --  ['http://json.schemastore.org/circleciconfig'] = '.circleci/**/*.{yml,yaml}',
            --  ['https://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
            --  ['https://json.schemastore.org/cloudbuild'] = '*cloudbuild.{yml,yaml}',
            --  ['https://taskfile.dev/schema.json'] = '**/{Taskfile,taskfile}.{yml,yaml}',
            --  ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '**/*.docker-compose.{yml,yaml}',
            --}
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
        settings = {
          ['Lua'] = {
            runtime = {
              version = "LuaJIT",
            },
            telemetry = {
              enable = false,
            },
            diagnostics = {
              globals = { 'vim' },
              unusedLocalExclude = {
                '_*'
              }
            },
          },
        },
      }
    end,
  },
}

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'b0o/SchemaStore.nvim',
    },
    config = function()
      vim.lsp.log.set_level('warn')

      local on_attach = function(_client, bufnr)
        local wk = require('which-key')
        -- stylua: ignore start
        wk.add({
          { '<Leader>l', buffer = bufnr, group = 'LSP' },
          { '<Leader>lds', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', buffer = bufnr, desc = 'Document Symbols' },
          { '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', buffer = bufnr, desc = 'Code Action' },
          { '<Leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>', buffer = bufnr, desc = 'Go to Definition' },
          { '<Leader>le', '<cmd>lua vim.diagnostic.open_float()<CR>', buffer = bufnr, desc = 'Show Diagnostic' },
          { '<Leader>lf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', buffer = bufnr, desc = 'Format' },
          { '<Leader>lh', '<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>', buffer = bufnr, desc = 'Inlay Hints' },
          { 'K', "<cmd>lua vim.lsp.buf.hover({ border = 'rounded' })<CR>", buffer = bufnr, desc = 'Hover' },
          { '<Leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>', buffer = bufnr, desc = 'Go to Implementation' },
          { '<Leader>lrf', '<cmd>lua vim.lsp.buf.references()<CR>', buffer = bufnr, desc = 'References' },
          { '<Leader>lrn', '<cmd>lua vim.lsp.buf.rename()<CR>', buffer = bufnr, desc = 'Rename' },
          { '<Leader>lsig', '<cmd>lua vim.lsp.buf.signature_help()<CR>', buffer = bufnr, desc = 'Signature Help' },
          { '<Leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', buffer = bufnr, desc = 'Type Definition' },
          { '<Leader>d[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', buffer = bufnr, desc = 'Go to previous diagnostic' },
          { '<Leader>d]', '<cmd>lua vim.diagnostic.goto_next()<CR>', buffer = bufnr, desc = 'Go to next diagnostic' },
          { '<Leader>ldl', '<cmd>Telescope diagnostics<CR>', buffer = bufnr, desc = 'List Diagnostics' },
        })
        -- stylua: ignore end
      end

      vim.lsp.config('*', {
        on_attach = on_attach,
        flags = {
          debounce_text_changes = 150,
        },
        capabilities = vim.tbl_deep_extend(
          'force',
          vim.lsp.protocol.make_client_capabilities(),
          require('cmp_nvim_lsp').default_capabilities()
        ),
      })

      local server_configs = {
        clangd = {
          filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
          cmd = { 'clangd', '--background-index' },
        },
        gopls = {},
        ts_ls = {},
        pyright = {},
        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = '',
              },
              schemas = require('schemastore').yaml.schemas(),
            },
          },
        },
        terraformls = {},
        buf_ls = {},
        lua_ls = {
          settings = {
            ['Lua'] = {
              runtime = {
                version = 'LuaJIT',
              },
              telemetry = {
                enable = false,
              },
              diagnostics = {
                globals = { 'vim' },
                unusedLocalExclude = {
                  '_*',
                },
              },
              format = {
                enable = false, -- Disable lua_ls formatter, use StyLua instead
              },
            },
          },
        },
      }

      for server_name, config in pairs(server_configs) do
        --vim.lsp.config(server_name, vim.tbl_deep_extend('force', common_config, config))
        vim.lsp.config(server_name, config)
        --print("enable LSP server: " .. server_name)
        --print("config: " .. vim.inspect(config))
        vim.lsp.enable(server_name)
      end
    end,
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Toggle Trouble' },
    },
    opts = {
      icons = {
        error = '',
        warning = '',
        hint = '',
        info = '',
      },
    },
  },
  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    event = 'LspAttach',
    config = function()
      require('aerial').setup({
        on_attach = function(bufnr)
          local wk = require('which-key')
          -- stylua: ignore start
          wk.add({
            { '{', '<cmd>AerialPrev<CR>', desc = 'Aerial Prev', buffer = bufnr },
            { '}', '<cmd>AerialNext<CR>', desc = 'Aerial Next', buffer = bufnr },
          })
          -- stylua: ignore end
        end,
        backends = { 'lsp', 'treesitter', 'markdown', 'asciidoc', 'man' },
        layout = {
          default_direction = 'prefer_left',
          resize_to_content = true,
        },
        lsp = {
          diagnostics_trigger_update = true,
          update_when_errors = true,
          update_delay = 1000,
        },
        treesitter = {
          update_delay = 1000,
        },
        markdown = {
          update_delay = 1000,
        },

        asciidoc = {
          update_delay = 1000,
        },
        man = {
          update_delay = 1000,
        },
      })
      local wk = require('which-key')
      -- stylua: ignore start
      wk.add({
        { '<Leader>lo', '<cmd>AerialToggle!<CR>', desc = 'Toggle Aerial (Outline)' },
      })
      -- stylua: ignore end
    end,
  },
  {
    'ray-x/lsp_signature.nvim',
    event = 'VeryLazy',
    config = function()
      require('lsp_signature').setup({
        bind = true,
        handler_opts = {
          border = 'rounded',
        },
      })
    end,
  },
  {
    'RRethy/vim-illuminate',
    event = 'LspAttach',
    config = function()
      require('illuminate').configure({
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
        delay = 1000,
      })
      local wk = require('which-key')
      -- stylua: ignore start
      wk.add({
        { ']]', function() require('illuminate').goto_next_reference(false) end, desc = 'Next Reference' },
        { '[[', function() require('illuminate').goto_prev_reference(false) end, desc = 'Prev Reference' },
      })
      -- stylua: ignore end
    end,
  },
  {
    'smjonas/inc-rename.nvim',
    enabled = false,
    event = 'LspAttach',
    config = function()
      require('inc_rename').setup({})

      local wk = require('which-key')
      -- stylua: ignore start
      wk.add({
        { '<Leader>lrn', function() return ':IncRename ' .. vim.fn.expand('<cword>') end, desc = 'Rename (Incremental)', expr = true },
      })
      -- stylua: ignore end
    end,
  },
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
    ft = { 'rust' },
    config = function()
      -- https://github.com/mrcjkb/rustaceanvim?tab=readme-ov-file#gear-advanced-configuration
      vim.g.rustaceanvim = {
        tools = {
          float_win_config = {
            border = 'rounded',
          },
        },
        server = {
          on_attach = function(_client, bufnr)
            local wk = require('which-key')
            -- stylua: ignore start
            wk.add({
              { '<Leader>l', buffer = bufnr, group = 'LSP' },
              { '<Leader>lds', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', buffer = bufnr, desc = 'Document Symbols' },
              { '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', buffer = bufnr, desc = 'Code Action' },
              { '<Leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>', buffer = bufnr, desc = 'Go to Definition' },
              { '<Leader>le', '<cmd>lua vim.diagnostic.open_float()<CR>', buffer = bufnr, desc = 'Show Diagnostic' },
              { '<Leader>lf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', buffer = bufnr, desc = 'Format' },
              { '<Leader>lh', '<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>', buffer = bufnr, desc = 'Inlay Hints' },
              { 'K', "<cmd>lua vim.lsp.buf.hover({ border = 'rounded' })<CR>", buffer = bufnr, desc = 'Hover' },
              { '<Leader>li', '<cmd>lua vim.lsp.buf.implementation()<CR>', buffer = bufnr, desc = 'Go to Implementation' },
              { '<Leader>lrf', '<cmd>lua vim.lsp.buf.references()<CR>', buffer = bufnr, desc = 'References' },
              { '<Leader>lrn', '<cmd>lua vim.lsp.buf.rename()<CR>', buffer = bufnr, desc = 'Rename' },
              { '<Leader>lsig', '<cmd>lua vim.lsp.buf.signature_help()<CR>', buffer = bufnr, desc = 'Signature Help' },
              { '<Leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', buffer = bufnr, desc = 'Type Definition' },
              { '<Leader>d[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', buffer = bufnr, desc = 'Go to previous diagnostic' },
              { '<Leader>d]', '<cmd>lua vim.diagnostic.goto_next()<CR>', buffer = bufnr, desc = 'Go to next diagnostic' },
              { '<Leader>ldl', '<cmd>Telescope diagnostics<CR>', buffer = bufnr, desc = 'List Diagnostics' },
              { '<Leader>lrh', "<cmd>lua vim.cmd.RustLsp {'hover', 'actions'}<CR>", buffer = bufnr, desc = 'Hover Actions' },
              { '<Leader>la', "<cmd>lua vim.cmd.RustLsp('codeAction')<CR>", buffer = bufnr, desc = 'Code Action' },
              { '<Leader>lem', "<cmd>lua vim.cmd.RustLsp('expandMacro')<CR>", buffer = bufnr, desc = 'Expand macros recursively' },
              { '<Leader>lrm', "<cmd>lua vim.cmd.RustLsp('rebuildProcMacros')<CR>", buffer = bufnr, desc = 'Rebuild proc macro' },
              { '<Leader>lmu', "<cmd>lua vim.cmd.RustLsp {'moveItem', 'up'}<CR>", buffer = bufnr, desc = 'Move item up' },
              { '<Leader>lmd', "<cmd>lua vim.cmd.RustLsp {'moveItem', 'down'}<CR>", buffer = bufnr, desc = 'Move item down' },
              { '<Leader>lee', "<cmd>lua vim.cmd.RustLsp('explainError')<CR>", buffer = bufnr, desc = 'Explain error' },
              { '<Leader>lrd', "<cmd>lua vim.cmd.RustLsp('renderDiagnostic')<CR>", buffer = bufnr, desc = 'Render diagnostics' },
              { '<Leader>ljd', "<cmd>lua vim.cmd.RustLsp('relatedDiagnostics')<CR>", buffer = bufnr, desc = 'Jump to related diagnostics' },
              { '<Leader>loc', "<cmd>lua vim.cmd.RustLsp('openCargo')<CR>", buffer = bufnr, desc = 'Open Cargo.toml' },
              { '<Leader>lod', "<cmd>lua vim.cmd.RustLsp('openDocs')<CR>", buffer = bufnr, desc = 'Open docs.rs' },
              { '<Leader>lpm', "<cmd>lua vim.cmd.RustLsp('parentModule')<CR>", buffer = bufnr, desc = 'Parent module' },
              { '<Leader>lcg', "<cmd>lua vim.cmd.RustLsp {'crateGraph', '[backend]', '[output]'}<CR>", buffer = bufnr, desc = 'Crate graph' },
              { '<Leader>lst', "<cmd>lua vim.cmd.RustLsp('syntaxTree')<CR>", buffer = bufnr, desc = 'View syntax tree' },
            })
            -- stylua: ignore end
          end,
          default_settings = {
            -- https://rust-analyzer.github.io/book/configuration
            ['rust-analyzer'] = {
              cargo = {
                buildScripts = {
                  enable = true,
                },
                targetDir = 'target/rust_analyzer',
              },
              check = {
                command = 'clippy',
                extraArgs = {
                  '--all-features',
                },
              },
              trace = { server = 'warn' },
            },
          },
        },
      }
    end,
  },
}

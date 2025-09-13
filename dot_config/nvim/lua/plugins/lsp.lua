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
        wk.add({
          { '<Leader>l', buffer = bufnr, group = 'LSP', remap = false },
          {
            '<Leader>lds',
            '<cmd>lua vim.lsp.buf.document_symbol()<CR>',
            buffer = bufnr,
            desc = 'Document Symbols',
            remap = false,
          },
          {
            '<Leader>la',
            '<cmd>lua vim.lsp.buf.code_action()<CR>',
            buffer = bufnr,
            desc = 'Code Action',
            remap = false,
          },
          {
            '<Leader>ld',
            '<cmd>lua vim.lsp.buf.definition()<CR>',
            buffer = bufnr,
            desc = 'Go to Definition',
            remap = false,
          },
          {
            '<Leader>le',
            '<cmd>lua vim.diagnostic.open_float()<CR>',
            buffer = bufnr,
            desc = 'Show Diagnostic',
            remap = false,
          },
          {
            '<Leader>lf',
            '<cmd>lua vim.lsp.buf.format({ async = true })<CR>',
            buffer = bufnr,
            desc = 'Format',
            remap = false,
          },
          {
            '<Leader>lh',
            '<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>',
            buffer = bufnr,
            desc = 'Inlay Hints',
            remap = false,
          },
          -- overrides the default keybinding to change the border to rounded
          {
            'K',
            "<cmd>lua vim.lsp.buf.hover({ border = 'rounded' })<CR>",
            buffer = bufnr,
            desc = 'Hover',
            remap = false,
          },
          {
            '<Leader>li',
            '<cmd>lua vim.lsp.buf.implementation()<CR>',
            buffer = bufnr,
            desc = 'Go to Implementation',
            remap = false,
          },
          {
            '<Leader>lrf',
            '<cmd>lua vim.lsp.buf.references()<CR>',
            buffer = bufnr,
            desc = 'References',
            remap = false,
          },
          {
            '<Leader>lrn',
            '<cmd>lua vim.lsp.buf.rename()<CR>',
            buffer = bufnr,
            desc = 'Rename',
            remap = false,
          },
          {
            '<Leader>lsig',
            '<cmd>lua vim.lsp.buf.signature_help()<CR>',
            buffer = bufnr,
            desc = 'Signature Help',
            remap = false,
          },
          {
            '<Leader>lt',
            '<cmd>lua vim.lsp.buf.type_definition()<CR>',
            buffer = bufnr,
            desc = 'Type Definition',
            remap = false,
          },
          {
            '<Leader>d[',
            '<cmd>lua vim.diagnostic.goto_prev()<CR>',
            buffer = bufnr,
            desc = 'Go to previous diagnostic',
            remap = false,
          },
          {
            '<Leader>d]',
            '<cmd>lua vim.diagnostic.goto_next()<CR>',
            buffer = bufnr,
            desc = 'Go to next diagnostic',
            remap = false,
          },
          {
            '<Leader>ldl',
            '<cmd>Telescope diagnostics<CR>',
            buffer = bufnr,
            desc = 'List Diagnostics',
            remap = false,
          },
        })
      end

      local lsp_flags = {
        debounce_text_changes = 150,
      }

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

      local common_config = {
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = vim.tbl_deep_extend(
          'force',
          vim.lsp.protocol.make_client_capabilities(),
          require('cmp_nvim_lsp').default_capabilities()
        ),
      }

      for server_name, config in pairs(server_configs) do
        vim.lsp.config(server_name, vim.tbl_deep_extend('force', common_config, config))
        vim.lsp.enable(server_name)
      end
    end,
  },
  {
    -- https://github.com/folke/trouble.nvim/pull/656
    --'folke/trouble.nvim',
    'h-michael/trouble.nvim',
    branch = 'fix/decoration-provider-api',
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
          wk.add({
            { '{', '<cmd>AerialPrev<CR>', desc = 'Aerial Prev', buffer = bufnr, remap = false },
            { '}', '<cmd>AerialNext<CR>', desc = 'Aerial Next', buffer = bufnr, remap = false },
          })
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
      wk.add({
        { '<Leader>lo', '<cmd>AerialToggle!<CR>', desc = 'Toggle Aerial (Outline)', remap = false },
      })
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
      wk.add({
        {
          ']]',
          function()
            require('illuminate').goto_next_reference(false)
          end,
          desc = 'Next Reference',
          remap = false,
        },
        {
          '[[',
          function()
            require('illuminate').goto_prev_reference(false)
          end,
          desc = 'Prev Reference',
          remap = false,
        },
      })
    end,
  },
  {
    'smjonas/inc-rename.nvim',
    enabled = false,
    event = 'LspAttach',
    config = function()
      require('inc_rename').setup({})

      local wk = require('which-key')
      wk.add({
        {
          '<Leader>lrn',
          function()
            return ':IncRename ' .. vim.fn.expand('<cword>')
          end,
          desc = 'Rename (Incremental)',
          remap = false,
          expr = true,
        },
      })
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
            wk.add({
              { '<Leader>l', buffer = bufnr, group = 'LSP', remap = false },
              {
                '<Leader>lds',
                '<cmd>lua vim.lsp.buf.document_symbol()<CR>',
                buffer = bufnr,
                desc = 'Document Symbols',
                remap = false,
              },
              {
                '<Leader>la',
                '<cmd>lua vim.lsp.buf.code_action()<CR>',
                buffer = bufnr,
                desc = 'Code Action',
                remap = false,
              },
              {
                '<Leader>ld',
                '<cmd>lua vim.lsp.buf.definition()<CR>',
                buffer = bufnr,
                desc = 'Go to Definition',
                remap = false,
              },
              {
                '<Leader>le',
                '<cmd>lua vim.diagnostic.open_float()<CR>',
                buffer = bufnr,
                desc = 'Show Diagnostic',
                remap = false,
              },
              {
                '<Leader>lf',
                '<cmd>lua vim.lsp.buf.format({ async = true })<CR>',
                buffer = bufnr,
                desc = 'Format',
                remap = false,
              },
              {
                '<Leader>lh',
                '<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>',
                buffer = bufnr,
                desc = 'Inlay Hints',
                remap = false,
              },
              -- overrides the default keybinding to change the border to rounded
              {
                'K',
                "<cmd>lua vim.lsp.buf.hover({ border = 'rounded' })<CR>",
                buffer = bufnr,
                desc = 'Hover',
                remap = false,
              },
              {
                '<Leader>li',
                '<cmd>lua vim.lsp.buf.implementation()<CR>',
                buffer = bufnr,
                desc = 'Go to Implementation',
                remap = false,
              },
              {
                '<Leader>lrf',
                '<cmd>lua vim.lsp.buf.references()<CR>',
                buffer = bufnr,
                desc = 'References',
                remap = false,
              },
              {
                '<Leader>lrn',
                '<cmd>lua vim.lsp.buf.rename()<CR>',
                buffer = bufnr,
                desc = 'Rename',
                remap = false,
              },
              {
                '<Leader>lsig',
                '<cmd>lua vim.lsp.buf.signature_help()<CR>',
                buffer = bufnr,
                desc = 'Signature Help',
                remap = false,
              },
              {
                '<Leader>lt',
                '<cmd>lua vim.lsp.buf.type_definition()<CR>',
                buffer = bufnr,
                desc = 'Type Definition',
                remap = false,
              },
              {
                '<Leader>d[',
                '<cmd>lua vim.diagnostic.goto_prev()<CR>',
                buffer = bufnr,
                desc = 'Go to previous diagnostic',
                remap = false,
              },
              {
                '<Leader>d]',
                '<cmd>lua vim.diagnostic.goto_next()<CR>',
                buffer = bufnr,
                desc = 'Go to next diagnostic',
                remap = false,
              },
              {
                '<Leader>ldl',
                '<cmd>Telescope diagnostics<CR>',
                buffer = bufnr,
                desc = 'List Diagnostics',
                remap = false,
              },

              -- overrides the default keybinding to change the border to rounded
              {
                '<Leader>lrh',
                "<cmd>lua vim.cmd.RustLsp {'hover', 'actions'}<CR>",
                desc = 'Hover Actions',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>la',
                "<cmd>lua vim.cmd.RustLsp('codeAction')<CR>",
                desc = 'Code Action',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lem',
                "<cmd>lua vim.cmd.RustLsp('expandMacro')<CR>",
                desc = 'Expand macros recursively',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lrm',
                "<cmd>lua vim.cmd.RustLsp('rebuildProcMacros')<CR>",
                desc = 'Rebuild proc macro',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lmu',
                "<cmd>lua vim.cmd.RustLsp {'moveItem', 'up'}<CR>",
                desc = 'Move item up',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lmd',
                "<cmd>lua vim.cmd.RustLsp {'moveItem', 'down'}<CR>",
                desc = 'Move item down',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lee',
                "<cmd>lua vim.cmd.RustLsp('explainError')<CR>",
                desc = 'Explain error',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lrd',
                "<cmd>lua vim.cmd.RustLsp('renderDiagnostic')<CR>",
                desc = 'Render diagnostics',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>ljd',
                "<cmd>lua vim.cmd.RustLsp('relatedDiagnostics')<CR>",
                desc = 'Jump to related diagnostics',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>loc',
                "<cmd>lua vim.cmd.RustLsp('openCargo')<CR>",
                desc = 'Open Cargo.toml',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lod',
                "<cmd>lua vim.cmd.RustLsp('openDocs')<CR>",
                desc = 'Open docs.rs',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lpm',
                "<cmd>lua vim.cmd.RustLsp('parentModule')<CR>",
                desc = 'Parent module',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lcg',
                "<cmd>lua vim.cmd.RustLsp {'crateGraph', '[backend]', '[output]'}<CR>",
                desc = 'Crate graph',
                buffer = bufnr,
                remap = false,
              },
              {
                '<Leader>lst',
                "<cmd>lua vim.cmd.RustLsp('syntaxTree')<CR>",
                desc = 'View syntax tree',
                buffer = bufnr,
                remap = false,
              },
            })
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

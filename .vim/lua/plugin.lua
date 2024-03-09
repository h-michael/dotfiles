-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- A solid language pack for Vim.
  use {
    'sheerun/vim-polyglot',
    setup = function()
      vim.g.polyglot_disabled = { 'sensible', 'rust' }
    end,
  }

  use {
    'rust-lang/rust.vim',
    setup = function()
      vim.g.rustfmt_emit_files = 1
      --vim.g.rustfmt_autosave = 1
    end,
  }

  use 'editorconfig/editorconfig-vim'

  use 'mechatroner/rainbow_csv'

  --use 'williamboman/mason-lspconfig.nvim'
  --use {
  --  'williamboman/mason.nvim',
  --  config = function()
  --    require("mason").setup()
  --  end
  --}

  use {
    'nanotech/jellybeans.vim',
    opt = true,
    setup = function()
      vim.opt.background = 'dark'
      vim.api.nvim_command [[colorscheme jellybeans]]
    end,
  }
  use {
    'nvim-lualine/lualine.nvim',
    event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
    requires = { 'nanotech/jellybeans.vim', 'nvim-lua/lsp-status.nvim' },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = 'auto',
          component_separators = { left = '|', right = '|'},
          section_separators = { left = '|', right = '|'},
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
      }
    end,
  }

  use 'tpope/vim-commentary'
  use 'jiangmiao/auto-pairs'

  -- use {
  --   'junegunn/fzf',
  --   run = './install --all',
  --   opt = true,
  -- }
  use {
    'ibhagwan/fzf-lua',
    config = function()
      local api = vim.api
      api.nvim_create_user_command(
        'Rg',
        function(_opts)
          require('fzf-lua').grep({
            rg_opts = '--column --line-number --no-heading --color=always --smart-case'
          })
        end,
        { bang = true, nargs = '*' }
      )
      api.nvim_create_user_command(
        'CurrentWordRg',
        function(_opts)
          require('fzf-lua').grep({
            rg_opts = '--column --line-number --no-heading --color=always --smart-case'
          })
        end,
        { bang = true, nargs = '*' }
      )
      api.nvim_create_user_command(
        'CurrentBufferDir',
        function(_opts)
          require('fzf-lua').files({ cwd = vim.fn.expand('%:p:h') })
        end,
        { bang = true, nargs = '?' }
      )
      api.nvim_create_user_command(
        'ProjectDir',
        function(_opts)
          require('fzf-lua').files({ cwd = vim.fn.getcwd() })
        end,
        { bang = true, nargs = '?' }
      )
      opt = { noremap = true, silent = true }
      vim.api.nvim_set_keymap('n', '/', "<cmd>lua require('fzf-lua').blines({ winopts = { preview = { hidden = 'hidden' } } })<CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>cw', "<cmd>lua require('fzf-lua').grep_cword()<CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>cbd', ":CurrentBufferDir <CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>pd', ":ProjectDir <CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>rg', ":Rg <CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>gr', ":Rg <CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>b', "<cmd>lua require('fzf-lua').buffers()<CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>f', "<cmd>lua require('fzf-lua').files()<CR>", opt)
      vim.api.nvim_set_keymap('n', '<Leader>t', "<cmd>lua require('fzf-lua').tags()<CR>", opt)
    end,
  }
  use 'bfredl/nvim-luadev'

  --  Plugin for vim to enabling opening a file in a given line
  use 'bogado/file-line'

  -- Vim and Neovim plugin to reveal the commit messages under the cursor
  use {
    'rhysd/git-messenger.vim',
    cmd = { 'GitMessenger', 'GitMessengerClose' }
  }
  -- Benchmarck
  use {
    'tweekmonster/startuptime.vim',
    cmd = { 'StartupTime' },
  }

  -- Edit vinari
  use {
    'Shougo/vinarise.vim',
    cmd = { 'Vinarise' },
  }

  -- endwise.vim: wisely add "end" in ruby, endfunction/endif/more in vim script, etc
  use {
    'tpope/vim-endwise',
    ft = { 'ruby' },
  }

  use {
    'preservim/tagbar',
    cmd = { 'TabbarToggle', 'TagbarOpen' },
    config = function()
      vim.api.nvim_set_keymap('n' ,'<Leader>tb', ':TagbarToggle<CR>', { noremap = true, silent = true })
    end,
  }

  -- simple memo plugin for Vim.
  use {
    'glidenote/memolist.vim',
    cmd = { 'MemoNew', 'MemoList', 'MemoGrep' },
    config = function()
      vim.api.nvim_set_keymap('n' ,'<Leader>mn', ':MemoNew<CR>', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('n' ,'<Leader>ml', ':MemoList<CR>', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('n' ,'<Leader>mg', ':MemoGrep<CR>', { noremap = false, silent = false })
    end,
  }

  -- Open GitHub URL of current file, etc. from Vim editor (supported GitHub Enterprise)
  use {
    'tyru/open-browser-github.vim',
    requires = { 'tyru/open-browser.vim' },
    cmd = { 'OpenGithubFile', 'OpenGithubIssue', 'OpenGithubPullReq' },
  }

  use {
    'rhysd/rust-doc.vim',
    ft = { 'help' },
  }

  use {
    'mattn/vim-goimports',
    ft = { 'go', 'gomod' },
  }

  use {
    'mattn/vim-goaddtags',
    ft = { 'go', 'gomod' },
  }

  use {
    'mattn/vim-gorename',
    ft = { 'go', 'gomod' },
  }

  use { 'github/copilot.vim' }

  use {
    'hrsh7th/nvim-cmp',
    requires = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-cmdline' },
      { 'hrsh7th/cmp-vsnip' },
      { 'hrsh7th/vim-vsnip' },
    },
    config = function()
      local cmp = require'cmp'
      require'cmp'.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'vsnip' },
          { name = 'cmdline' },
        })
      })
    end,
  }

  use {
    'neovim/nvim-lspconfig',
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local os_getenv = vim.loop.os_getenv

      local on_attach = function(_client, _bufnr)
        local opts = { noremap = true, silent = true }
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
      end

      local lsp_flags = {
        debounce_text_changes = 150,
      }

      require('lspconfig')['clangd'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
        cmd = {"clangd", "--background-index"},
      }
      require('lspconfig')['rust_analyzer'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              buildScripts = {
                enable = true,
              }
            }
          }
        },
      }
      require('lspconfig')['gopls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      require('lspconfig')['solargraph'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
      require('lspconfig')['tsserver'].setup{
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
            }
          }
        },
      }
      require('lspconfig')['terraformls'].setup{
        on_attach = on_attach,
        flags = lsp_flags,
        capabilities = capabilities,
      }
    end,
  }

  use {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config({
        virtual_text = false,
      })
    end,
  }
end)

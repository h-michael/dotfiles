return {
  {
    'nanotech/jellybeans.vim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = 'dark'
      vim.cmd [[colorscheme jellybeans]]
    end,
  },
  {
    'rhysd/rust-doc.vim',
    ft = { 'help' },
  },
  {
    'saecki/crates.nvim',
    tag = 'stable',
    event = "BufRead Cargo.toml",
    config = function()
      require('crates').setup()
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup {}
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
    dependencies = {
      'nanotech/jellybeans.vim',
      'folke/trouble.nvim',
    },
    config = function()
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "lsp_document_symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_d_normal",
      })

      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = ' ', right = ' '},
          section_separators = { left = ' ', right = ' '},
          padding = 0,
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
          },
          path = 4,
        },
        sections = {
          lualine_a = { { 'mode', fmt = function(str) return " " .. str:sub(1,1) .. " " end } },
          lualine_b = { 'branch' },
          lualine_c = { 'filename' },
          lualine_d = { symbols.get, cond = symbols.has },
          lualine_x = { 'diagnostics' },
          lualine_y = { 'encoding', 'fileformat', 'filetype' },
          lualine_z = { 'progress', 'location' }
        },
        inactive_sections = {
          lualine_a = { 'filename' },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
      }
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter", -- Load the plugin only when entering insert mode for faster startup.
    config = function()
      local autopairs = require('nvim-autopairs')
      autopairs.setup({
        -- Enable Treesitter integration for smarter pairing based on syntax context.
        check_ts = true,
        -- Disable autopairs in specific filetypes, e.g., Telescope prompts.
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
      })

      -- Integration with nvim-cmp.
      -- This is crucial for a smooth completion experience, preventing redundant pairs
      -- when confirming a completion item.
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },
  { 'bfredl/nvim-luadev' },
  --  Plugin for vim to enabling opening a file in a given line
  {'bogado/file-line' },
  -- Vim and Neovim plugin to reveal the commit messages under the cursor
  {
    'rhysd/git-messenger.vim',
    cmd = { 'GitMessenger', 'GitMessengerClose' }
  },
  -- Benchmarck
  {
    'tweekmonster/startuptime.vim',
    cmd = { 'StartupTime' },
  },
  -- Edit vinari
  {
    'Shougo/vinarise.vim',
    cmd = { 'Vinarise' },
  },
  -- endwise.vim: wisely add "end" in ruby, endfunction/endif/more in vim script, etc
  {
    'tpope/vim-endwise',
    ft = { 'ruby' },
  },
  {
    'preservim/tagbar',
    cmd = { 'TabbarToggle', 'TagbarOpen' },
    config = function()
      vim.api.nvim_set_keymap('n' ,'<Leader>tb', ':TagbarToggle<CR>', { noremap = true, silent = true })
    end,
  },
  -- simple memo plugin for Vim.
  {
    'glidenote/memolist.vim',
    cmd = { 'MemoNew', 'MemoList', 'MemoGrep' },
  },
  -- Open GitHub URL of current file, etc. from Vim editor (supported GitHub Enterprise)
  {
    'tyru/open-browser-github.vim',
    dependencies = { 'tyru/open-browser.vim' },
    cmd = { 'OpenGithubFile', 'OpenGithubIssue', 'OpenGithubPullReq' },
  },
  {
    'github/copilot.vim',
    enabled = true,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-cmdline' },
      { 'hrsh7th/cmp-vsnip' },
      { 'hrsh7th/vim-vsnip' },
      { "olimorris/codecompanion.nvim" },
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
          { name = "copilot" },
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'vsnip' },
          { name = 'cmdline' },
          { name = 'codecompanion'}
        })
      })
    end,
  },
  {
    'ibhagwan/fzf-lua',
    enabled = false,
    config = function()
      require('fzf-lua').register_ui_select()

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
      local opt = { noremap = true, silent = true }
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
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<C-h>", "<cmd>WhichKey<CR>", mode = "n", desc = "WhichKey" },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    enabled = false,
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    opts = {
      opts = {
        log_level = "INFO",
      },
    },
    config = function()
      require("codecompanion").setup({
        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = "Prompt ",
            provider = "telescope",
            opts = {
              show_default_actions = true,
              show_default_prompt_library = true,
              title = "CodeCompanion actions",
            },
          },
        },
        strategies = {
          chat = {
            adapter = function()
              return require("codecompanion.adapters").extend("gemini_cli", {
                commands = {
                   default = {
                     "gemini",
                     "--experimental-acp",
                   },
                   flash = {
                     "gemini",
                     "--experimental-acp",
                     "-m",
                     "gemini-2.5-flash",
                   },
                   pro = {
                     "gemini",
                     "--experimental-acp",
                     "-m",
                     "gemini-2.5-pro",
                   },
                },
                defaults = {
                  auth_method = "oauth-personal",
                },
              })
            end
          },
        },
        adapters = {
          http = nil,
          acp = {
            gemini_cli = function()
              return require("codecompanion.adapters").extend("gemini_cli", {
                commands = {
                   default = {
                     "gemini",
                     "--experimental-acp",
                   },
                   flash = {
                     "gemini",
                     "--experimental-acp",
                     "-m",
                     "gemini-2.5-flash",
                   },
                   pro = {
                     "gemini",
                     "--experimental-acp",
                     "-m",
                     "gemini-2.5-pro",
                   },
                },
                defaults = {
                  auth_method = "oauth-personal",
                },
              })
            end,
          },
        },
      })
    end,
  },
}

return {
  {
    'nanotech/jellybeans.vim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = 'dark'
      vim.cmd [[colorscheme jellybeans]]

      -- Set custom highlights for nvim-cmp kinds and menu
      local highlights = {
        CmpItemMenu = { fg = '#81a2be' },
        CmpItemKindFunction = { fg = '#81a2be' },
        CmpItemKindMethod = { fg = '#81a2be' },
        CmpItemKindConstructor = { fg = '#81a2be' },
        CmpItemKindVariable = { fg = '#b294bb' },
        CmpItemKindField = { fg = '#b294bb' },
        CmpItemKindClass = { fg = '#f0c674' },
        CmpItemKindStruct = { fg = '#f0c674' },
        CmpItemKindModule = { fg = '#f0c674' },
        CmpItemKindInterface = { fg = '#8abeb7' },
        CmpItemKindTypeParameter = { fg = '#8abeb7' },
        CmpItemKindConstant = { fg = '#de935f' },
        CmpItemKindEnum = { fg = '#de935f' },
        CmpItemKindEnumMember = { fg = '#de935f' },
        CmpItemKindKeyword = { fg = '#cc6666' },
        CmpItemKindSnippet = { fg = '#c5c8c6' },
        CmpItemKindText = { fg = '#c5c8c6' },
        CmpItemKindFile = { fg = '#c5c8c6' },
        CmpItemKindFolder = { fg = '#c5c8c6' },

        -- Completion Menu Background
        Pmenu = { bg = '#282a2e' },
        PmenuSel = { bg = '#81a2be', fg = '#151515' },
        PmenuSbar = { bg = '#373b41' },
        PmenuThumb = { bg = '#c5c8c6' },
      }

      for group, conf in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, conf)
      end
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
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
    dependencies = {
      'nanotech/jellybeans.vim',
    },
    config = function()
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

        map_cr = true,
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
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-nvim-lua" },
      { 'hrsh7th/cmp-buffer' },
      {
        'FelipeLema/cmp-async-path',
        url = 'https://codeberg.org/FelipeLema/cmp-async-path.git',
      },
      --{ 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-cmdline' },
      { 'olimorris/codecompanion.nvim' },
      { 'onsails/lspkind.nvim' },
    },
    config = function()
      require('lspkind').init({
        symbol_map = {
          Text = "󰉿 txt",
          Method = "󰆧 m",
          Function = "󰊕 f",
          Constructor = " new",
          Field = "󰜢 fld",
          Variable = "󰆨  var",
          Class = "󰠱  cls",
          Interface = "  IF",
          Module = "  mod",
          Property = "󰜢  prop",
          Unit = "󰑭  unit",
          Value = "󰎠  val",
          Enum = "  enum",
          Keyword = "󰌋  key",
          Snippet = "  snp",
          Color = "󰏘  color",
          File = "󰈙  file",
          Reference = "󰈇  ref",
          Folder = "󰉋  dir",
          EnumMember = "  member",
          Constant = "󰏿 const",
          Struct = "󰙅 struct",
          Event = "  event",
          Operator = "󰆕  op",
          TypeParameter = "󰊄 type",
        }
      })

      local cmp = require('cmp')
      require('cmp').setup({
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
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lua" },
          { name = 'buffer' },
          { name = 'async_path' },
          --{ name = 'path' },
          { name = 'cmdline' },
          { name = 'codecompanion'}
        }),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = require('lspkind').cmp_format({
            mode = 'symbol',
            menu = ({
              copilot = "[AI]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[Lua]",
              buffer = "[Buffer]",
              async_path = "[Path]",
              path = "[Path]",
              codecompanion = "[AI]",
            }),
            maxwidth = {
              -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
              -- can also be a function to dynamically calculate max width such as
              -- menu = function() return math.floor(0.45 * vim.o.columns) end,
              menu = 50, -- leading text (labelDetails)
              abbr = 50, -- actual suggestion item
            },
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default
          })
        },
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

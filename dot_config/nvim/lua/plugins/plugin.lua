return {
  {
    'rhysd/rust-doc.vim',
    ft = { 'help' },
  },
  {
    'saecki/crates.nvim',
    tag = 'stable',
    event = 'BufRead Cargo.toml',
    config = function()
      require('crates').setup()
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter', -- Load the plugin only when entering insert mode for faster startup.
    config = function()
      local autopairs = require('nvim-autopairs')
      autopairs.setup({
        -- Enable Treesitter integration for smarter pairing based on syntax context.
        check_ts = true,
        -- Disable autopairs in specific filetypes, e.g., Telescope prompts.
        disable_filetype = { 'TelescopePrompt', 'spectre_panel' },

        map_cr = true,
      })

      -- Integration with nvim-cmp.
      -- This is crucial for a smooth completion experience, preventing redundant pairs
      -- when confirming a completion item.
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  { 'bfredl/nvim-luadev' },
  --  Plugin for vim to enabling opening a file in a given line
  { 'bogado/file-line' },
  -- Vim and Neovim plugin to reveal the commit messages under the cursor
  {
    'rhysd/git-messenger.vim',
    cmd = { 'GitMessenger', 'GitMessengerClose' },
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
      vim.api.nvim_set_keymap('n', '<Leader>tb', ':TagbarToggle<CR>', { noremap = true, silent = true })
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
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-nvim-lua' },
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
          Text = '󰉿 txt',
          Method = '󰆧 m',
          Function = '󰊕 f',
          Constructor = ' new',
          Field = '󰜢 fld',
          Variable = '󰆨  var',
          Class = '󰠱  cls',
          Interface = '  IF',
          Module = '  mod',
          Property = '󰜢  prop',
          Unit = '󰑭  unit',
          Value = '󰎠  val',
          Enum = '  enum',
          Keyword = '󰌋  key',
          Snippet = '  snp',
          Color = '󰏘  color',
          File = '󰈙  file',
          Reference = '󰈇  ref',
          Folder = '󰉋  dir',
          EnumMember = '  member',
          Constant = '󰏿 const',
          Struct = '󰙅 struct',
          Event = '  event',
          Operator = '󰆕  op',
          TypeParameter = '󰊄 type',
        },
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
          { name = 'copilot' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'nvim_lua' },
          { name = 'buffer' },
          { name = 'async_path' },
          --{ name = 'path' },
          { name = 'cmdline' },
          { name = 'codecompanion' },
        }),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = require('lspkind').cmp_format({
            mode = 'symbol',
            menu = {
              copilot = '[AI]',
              nvim_lsp = '[LSP]',
              nvim_lua = '[Lua]',
              buffer = '[Buffer]',
              async_path = '[Path]',
              path = '[Path]',
              codecompanion = '[AI]',
            },
            maxwidth = {
              -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
              -- can also be a function to dynamically calculate max width such as
              -- menu = function() return math.floor(0.45 * vim.o.columns) end,
              menu = 50, -- leading text (labelDetails)
              abbr = 50, -- actual suggestion item
            },
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default
          }),
        },
      })
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { '<C-h>', '<cmd>WhichKey<CR>', mode = 'n', desc = 'WhichKey' },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    enabled = false,
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
    opts = {
      opts = {
        log_level = 'INFO',
      },
    },
    config = function()
      require('codecompanion').setup({
        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = 'Prompt ',
            provider = 'telescope',
            opts = {
              show_default_actions = true,
              show_default_prompt_library = true,
              title = 'CodeCompanion actions',
            },
          },
        },
        strategies = {
          chat = {
            adapter = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                commands = {
                  default = {
                    'gemini',
                    '--experimental-acp',
                  },
                  flash = {
                    'gemini',
                    '--experimental-acp',
                    '-m',
                    'gemini-2.5-flash',
                  },
                  pro = {
                    'gemini',
                    '--experimental-acp',
                    '-m',
                    'gemini-2.5-pro',
                  },
                },
                defaults = {
                  auth_method = 'oauth-personal',
                },
              })
            end,
          },
        },
        adapters = {
          http = nil,
          acp = {
            gemini_cli = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                commands = {
                  default = {
                    'gemini',
                    '--experimental-acp',
                  },
                  flash = {
                    'gemini',
                    '--experimental-acp',
                    '-m',
                    'gemini-2.5-flash',
                  },
                  pro = {
                    'gemini',
                    '--experimental-acp',
                    '-m',
                    'gemini-2.5-pro',
                  },
                },
                defaults = {
                  auth_method = 'oauth-personal',
                },
              })
            end,
          },
        },
      })
    end,
  },
}

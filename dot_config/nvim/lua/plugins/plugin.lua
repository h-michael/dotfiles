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
    'rust-lang/rust.vim',
    ft = 'rust',
    setup = function()
      vim.g.rustfmt_emit_files = 1
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    'rhysd/rust-doc.vim',
    ft = { 'help' },
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
    dependencies = { 'nanotech/jellybeans.vim', 'nvim-lua/lsp-status.nvim' },
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
  },
  { 'jiangmiao/auto-pairs' },
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
    config = function()
      vim.api.nvim_set_keymap('n' ,'<Leader>mn', ':MemoNew<CR>', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('n' ,'<Leader>ml', ':MemoList<CR>', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('n' ,'<Leader>mg', ':MemoGrep<CR>', { noremap = false, silent = false })
    end,
  },
  -- Open GitHub URL of current file, etc. from Vim editor (supported GitHub Enterprise)
  {
    'tyru/open-browser-github.vim',
    dependencies = { 'tyru/open-browser.vim' },
    cmd = { 'OpenGithubFile', 'OpenGithubIssue', 'OpenGithubPullReq' },
  },
  {
    'mattn/vim-goimports',
    ft = { 'go', 'gomod' },
  },
  {
    'mattn/vim-goaddtags',
    ft = { 'go', 'gomod' },
  },
  {
    'mattn/vim-gorename',
    ft = { 'go', 'gomod' },
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
        })
      })
    end,
  },
  {
    'ibhagwan/fzf-lua',
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
    opts = {
    },
    keys = {
      --{
      --  "<leader>?",
      --  function()
      --    require("which-key").show({ global = false })
      --  end,
      --  desc = "Buffer Local Keymaps (which-key)",
      --},
    },
  },
}

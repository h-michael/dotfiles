return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        on_highlights = function(hl, c)
          hl.WinSeparator = {
            fg = c.yellow,
          }
        end,
      })
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
  },
  {
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'nanotech/jellybeans.vim',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = 'dark'
      vim.cmd([[colorscheme jellybeans]])
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { 'InsertEnter', 'CursorHold', 'FocusLost', 'BufRead', 'BufNewFile' },
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = ' ', right = ' ' },
          section_separators = { left = ' ', right = ' ' },
          padding = 0,
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
          path = 4,
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(str)
                return ' ' .. str:sub(1, 1) .. ' '
              end,
            },
          },
          lualine_b = { 'branch' },
          lualine_c = { 'filename' },
          lualine_x = { 'diagnostics' },
          lualine_y = { 'encoding', 'fileformat', 'filetype' },
          lualine_z = { 'progress', 'location' },
        },
        inactive_sections = {
          lualine_a = { 'filename' },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {},
      })
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
  },
  {
    'nvim-mini/mini.icons',
    version = false,
  },
  {
    'rcarriga/nvim-notify',
    config = function()
      vim.notify = require('notify')
      require('notify').setup({
        fps = 60,
        stages = 'fade_in_slide_out',
        timeout = 2000,
        max_height = function()
          return math.floor(vim.o.lines * 0.40)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.40)
        end,
      })
      local severity = { 'error', 'warn', 'info', 'debug' }
      vim.lsp.handlers['window/showMessage'] = function(_err, method, params, _client_id)
        vim.notify(method.message, severity[params.type])
      end
    end,
  },
  {
    'catgoose/nvim-colorizer.lua',
    event = 'BufReadPre',
    opts = {
      filetypes = {
        'html',
        'css',
        'javascript',
        'typescript',
        'lua',
        'tmux',
        'sh',
        'bash',
        'zsh',
        'fish',
      },
    },
  },
  {
    'uga-rosa/ccc.nvim',
    cmd = { 'CccPick', 'CccConvert', 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccHighlighterDisable' },
  },
}

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd [[colorscheme tokyonight-night]]
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
  },
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
    'nvim-tree/nvim-web-devicons',
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { "InsertEnter", "CursorHold", "FocusLost", "BufRead", "BufNewFile" },
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
}

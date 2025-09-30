return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
    enabled = true,
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
    keys = {
      -- stylua: ignore start
      { '<leader>cc', '<cmd>CodeCompanionChat Toggle<CR>', mode = { 'n', 'v' }, desc = 'Toggle CodeCompanion chat' },
      { '<leader>ca', '<cmd>CodeCompanionActions<CR>', mode = { 'n', 'v' }, desc = 'CodeCompanion actions' },
      { '<leader>cp', '<cmd>CodeCompanion<CR>', mode = { 'n', 'v' }, desc = 'CodeCompanion prompt' },
      { '<leader>cs', '<cmd>CodeCompanionChat Add<CR>', mode = 'v', desc = 'Add selection to chat' },
      -- stylua: ignore end
    },
    config = function()
      require('codecompanion').setup({
        opts = {
          log_level = 'WARN',
        },
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
          chat = {
            window = {
              layout = 'vertical',
              width = 0.4,
              height = 0.8,
              border = 'rounded',
              position = 'right',
            },
          },
        },
        strategies = {
          chat = {
            adapter = 'claude_code',
          },
          inline = {
            adapter = 'copilot',
          },
          cmd = {
            adapter = 'claude_code',
          },
        },
        adapters = {
          acp = {
            claude_code = function()
              return require('codecompanion.adapters').extend('claude_code', {
                commands = {
                  default = {
                    'npx',
                    '--silent',
                    '--yes',
                    '@zed-industries/claude-code-acp',
                  },
                },
                defaults = {
                  mcpServers = {},
                  timeout = 30000, -- 30 seconds
                },
                env = {
                  CLAUDE_CODE_OAUTH_TOKEN = 'CLAUDE_CODE_OAUTH_TOKEN',
                },
              })
            end,
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
                    'gemini-2.0-flash',
                  },
                  pro = {
                    'gemini',
                    '--experimental-acp',
                    '-m',
                    'gemini-2.0-pro',
                  },
                  ['yolo-flash'] = {
                    'gemini',
                    '--experimental-acp',
                    '-m',
                    'gemini-2.0-flash',
                    '--yolo',
                  },
                  ['yolo-pro'] = {
                    'gemini',
                    '--experimental-acp',
                    '-m',
                    'gemini-2.0-pro',
                    '--yolo',
                  },
                },
                defaults = {
                  auth_method = 'oauth-personal',
                  mcpServers = {},
                  timeout = 30000, -- 30 seconds
                },
                env = {},
              })
            end,
          },
        },
      })
    end,
  },
}

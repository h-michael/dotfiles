return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions', 'CodeCompanionCmd' },
    keys = {
      -- stylua: ignore start
      -- Chat operations
      { '<leader>cc', '<cmd>CodeCompanionChat Toggle<CR>', mode = { 'n', 'v' }, desc = 'Toggle CodeCompanion chat' },
      { '<leader>ca', '<cmd>CodeCompanionActions<CR>', mode = { 'n', 'v' }, desc = 'CodeCompanion actions' },
      { '<leader>cp', '<cmd>CodeCompanion<CR>', mode = { 'n', 'v' }, desc = 'CodeCompanion prompt' },
      { '<leader>cs', '<cmd>CodeCompanionChat Add<CR>', mode = 'v', desc = 'Add selection to chat' },
      -- Adapter switching
      { '<leader>cac', '<cmd>CodeCompanionChat claude_code<CR>', mode = { 'n', 'v' }, desc = 'Chat with Claude Code' },
      { '<leader>cag', '<cmd>CodeCompanionChat gemini_cli<CR>', mode = { 'n', 'v' }, desc = 'Chat with Gemini CLI' },
      { '<leader>caf', '<cmd>CodeCompanionChat gemini_cli_flash<CR>', mode = { 'n', 'v' }, desc = 'Chat with Gemini Flash' },
      { '<leader>cap', '<cmd>CodeCompanionChat gemini_cli_pro<CR>', mode = { 'n', 'v' }, desc = 'Chat with Gemini Pro' },
      -- stylua: ignore end
    },
    config = function()
      require('codecompanion').setup({
        opts = {
          log_level = 'WARN', -- ERROR, WARN, INFO, DEBUG, TRACE
          language = 'Japanese',
        },
        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = 'Prompt ',
            provider = 'telescope', -- telescope, fzf_lua, mini_pick, snacks
            opts = {
              show_default_actions = true,
              show_default_prompt_library = true,
              title = 'CodeCompanion actions',
            },
          },
          chat = {
            icons = {
              buffer_pin = '📌 ',
              buffer_watch = '👀 ',
              chat_fold = '▼ ',
              tool_pending = '⏳ ',
              tool_in_progress = '⚙️ ',
              tool_failure = '❌ ',
              tool_success = '✅ ',
            },
            window = {
              layout = 'vertical', -- vertical, horizontal, float, buffer
              width = 0.4,
              relative = 'editor',
              border = 'rounded',
              position = 'right',
            },
            auto_scroll = true, -- Auto-scroll during LLM response
            intro_message = 'Welcome to CodeCompanion ✨! Press ? for options',
            show_header_separator = true, -- Show separator between messages (REQUIRED for separator to display)
            separator = '─', -- Separator between messages
            show_context = true, -- Display context from slash commands/variables (only when context exists)
            fold_context = false, -- Don't fold context (show it expanded)
            show_reasoning = true, -- Show reasoning from LLM (only when LLM provides reasoning)
            fold_reasoning = false, -- Don't fold reasoning (show it expanded)
            show_settings = true, -- Show adapter and model info at top
            show_tools_processing = true, -- Display loading when tools execute
            show_token_count = true, -- Display token usage (may not work with ACP adapters)
            start_in_insert_mode = false, -- Start in normal mode (required for intro_message)
            token_count = function(tokens, _adapter)
              return ' (' .. tokens .. ' tokens)'
            end,
          },
          inline = {
            layout = 'vertical', -- vertical, horizontal, buffer
          },
        },
        strategies = {
          chat = {
            adapter = 'claude_code', -- High-quality reasoning for chat
            roles = {
              llm = function(adapter)
                local model_name = ''
                if adapter.schema and adapter.schema.model and adapter.schema.model.default then
                  local model = adapter.schema.model.default
                  if type(model) == 'function' then
                    model = model(adapter)
                  end
                  model_name = ' (' .. model .. ')'
                end
                return '🤖 ' .. adapter.formatted_name .. model_name
              end,
              user = '👤 User',
            },
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
                env = {
                  CLAUDE_CODE_OAUTH_TOKEN = 'CLAUDE_CODE_OAUTH_TOKEN',
                },
              })
            end,
            gemini_cli = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                defaults = {
                  auth_method = 'oauth-personal', -- oauth-personal, gemini-api-key, vertex-ai
                },
                env = {},
              })
            end,
            gemini_cli_flash = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                commands = {
                  default = { 'gemini', '--experimental-acp', '-m', 'gemini-2.0-flash-exp' },
                },
                defaults = {
                  auth_method = 'oauth-personal',
                },
                env = {},
              })
            end,
            gemini_cli_pro = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                commands = {
                  default = { 'gemini', '--experimental-acp', '-m', 'gemini-2.0-pro-exp' },
                },
                defaults = {
                  auth_method = 'oauth-personal',
                },
                env = {},
              })
            end,
            gemini_cli_flash_yolo = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                commands = {
                  default = { 'gemini', '--yolo', '--experimental-acp', '-m', 'gemini-2.0-flash-exp' },
                },
                defaults = {
                  auth_method = 'oauth-personal',
                },
                env = {},
              })
            end,
          },
        },
        memory = {
          claude = {
            description = 'Memory files for Claude Code users',
            parser = 'claude',
            files = {
              '~/.claude/CLAUDE.md',
              'CLAUDE.md',
              'CLAUDE.local.md',
              'AGENTS.md',
              'AGENTS.local.md',
              'CONTEXT.md',
            },
          },
          gemini = {
            description = 'Memory files for Gemini CLI users',
            parser = 'none',
            files = {
              'AGENTS.md',
              'AGENTS.local.md',
              'CONTEXT.md',
              'GEMINI.md',
              'GEMINI.local.md',
            },
          },
          opts = {
            chat = {
              enabled = true,
              default_memory = { 'claude', 'gemini' },
            },
          },
        },
        tools = {
          opts = {
            auto_submit_errors = false,
            auto_submit_success = false,
          },
        },
      })
    end,
  },
}

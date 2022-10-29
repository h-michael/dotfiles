-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/hatahirokazu/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/hatahirokazu/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/hatahirokazu/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/hatahirokazu/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/hatahirokazu/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["auto-pairs"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/auto-pairs",
    url = "https://github.com/jiangmiao/auto-pairs"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  ["cmp-vsnip"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/cmp-vsnip",
    url = "https://github.com/hrsh7th/cmp-vsnip"
  },
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/editorconfig-vim",
    url = "https://github.com/editorconfig/editorconfig-vim"
  },
  ["file-line"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/file-line",
    url = "https://github.com/bogado/file-line"
  },
  fzf = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf-lua"] = {
    config = { "\27LJ\2\nƒ\1\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0B\1\2\1K\0\1\0\1\0\1\frg_optsD--column --line-number --no-heading --color=always --smart-case\tgrep\ffzf-lua\frequireƒ\1\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0B\1\2\1K\0\1\0\1\0\1\frg_optsD--column --line-number --no-heading --color=always --smart-case\tgrep\ffzf-lua\frequirel\0\1\a\0\t\0\r6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\a\0006\4\3\0009\4\4\0049\4\5\4'\6\6\0B\4\2\2=\4\b\3B\1\2\1K\0\1\0\bcwd\1\0\0\n%:p:h\vexpand\afn\bvim\nfiles\ffzf-lua\frequireb\0\1\6\0\b\0\f6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\6\0006\4\3\0009\4\4\0049\4\5\4B\4\1\2=\4\a\3B\1\2\1K\0\1\0\bcwd\1\0\0\vgetcwd\afn\bvim\nfiles\ffzf-lua\frequireÔ\a\1\0\a\0$\0a6\0\0\0009\0\1\0009\1\2\0'\3\3\0003\4\4\0005\5\5\0B\1\4\0019\1\2\0'\3\6\0003\4\a\0005\5\b\0B\1\4\0019\1\2\0'\3\t\0003\4\n\0005\5\v\0B\1\4\0019\1\2\0'\3\f\0003\4\r\0005\5\14\0B\1\4\0015\1\15\0007\1\16\0006\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\19\0'\5\20\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\21\0'\5\22\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\23\0'\5\24\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\25\0'\5\26\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\27\0'\5\28\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\29\0'\5\28\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\30\0'\5\31\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4 \0'\5!\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\"\0'\5#\0006\6\16\0B\1\5\1K\0\1\0+<cmd>lua require('fzf-lua').tags()<CR>\14<Leader>t,<cmd>lua require('fzf-lua').files()<CR>\14<Leader>f.<cmd>lua require('fzf-lua').buffers()<CR>\14<Leader>b\15<Leader>gr\r:Rg <CR>\15<Leader>rg\21:ProjectDir <CR>\15<Leader>pd\27:CurrentBufferDir <CR>\16<Leader>cbd1<cmd>lua require('fzf-lua').grep_cword()<CR>\15<Leader>cw^<cmd>lua require('fzf-lua').blines({ winopts = { preview = { hidden = 'hidden' } } })<CR>\6/\6n\20nvim_set_keymap\bopt\1\0\2\fnoremap\2\vsilent\2\1\0\2\tbang\2\nnargs\6?\0\15ProjectDir\1\0\2\tbang\2\nnargs\6?\0\21CurrentBufferDir\1\0\2\tbang\2\nnargs\6*\0\18CurrentWordRg\1\0\2\tbang\2\nnargs\6*\0\aRg\29nvim_create_user_command\bapi\bvim\0" },
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/fzf-lua",
    url = "https://github.com/ibhagwan/fzf-lua"
  },
  ["git-messenger.vim"] = {
    commands = { "GitMessenger", "GitMessengerClose" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/git-messenger.vim",
    url = "https://github.com/rhysd/git-messenger.vim"
  },
  ["jellybeans.vim"] = {
    config = { "\27LJ\2\no\0\0\3\0\a\0\n6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\4\0009\0\5\0'\2\6\0B\0\2\1K\0\1\0\27colorscheme jellybeans\17nvim_command\bapi\tdark\15background\bopt\bvim\0" },
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/jellybeans.vim",
    url = "https://github.com/nanotech/jellybeans.vim"
  },
  ["lsp-status.nvim"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/lsp-status.nvim",
    url = "https://github.com/nvim-lua/lsp-status.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\nö\5\0\0\6\0%\00096\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0004\5\0\0=\5\t\0044\5\0\0=\5\n\4=\4\v\0035\4\f\0=\4\r\3=\3\15\0025\3\17\0005\4\16\0=\4\18\0035\4\19\0=\4\20\0035\4\21\0=\4\22\0035\4\23\0=\4\24\0035\4\25\0=\4\26\0035\4\27\0=\4\28\3=\3\29\0025\3\30\0004\4\0\0=\4\18\0034\4\0\0=\4\20\0035\4\31\0=\4\22\0035\4 \0=\4\24\0034\4\0\0=\4\26\0034\4\0\0=\4\28\3=\3!\0024\3\0\0=\3\"\0024\3\0\0=\3\n\0024\3\0\0=\3#\0024\3\0\0=\3$\2B\0\2\1K\0\1\0\15extensions\20inactive_winbar\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\rsections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\4\0\0\rencoding\15fileformat\rfiletype\14lualine_c\1\2\0\0\rfilename\14lualine_b\1\4\0\0\vbranch\tdiff\16diagnostics\14lualine_a\1\0\0\1\2\0\0\tmode\foptions\1\0\0\frefresh\1\0\3\vwinbar\3è\a\ftabline\3è\a\15statusline\3è\a\23disabled_filetypes\vwinbar\15statusline\1\0\0\23section_separators\1\0\2\tleft\6|\nright\6|\25component_separators\1\0\2\tleft\6|\nright\6|\1\0\4\17globalstatus\1\25always_divide_middle\2\ntheme\tauto\18icons_enabled\1\nsetup\flualine\frequire\0" },
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["memolist.vim"] = {
    commands = { "MemoNew", "MemoList", "MemoGrep" },
    config = { "\27LJ\2\n‹\2\0\0\6\0\r\0\0256\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\a\0'\4\b\0005\5\t\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\n\0'\4\v\0005\5\f\0B\0\5\1K\0\1\0\1\0\2\fnoremap\1\vsilent\1\18:MemoGrep<CR>\15<Leader>mg\1\0\2\fnoremap\1\vsilent\1\18:MemoList<CR>\15<Leader>ml\1\0\2\fnoremap\1\vsilent\1\17:MemoNew<CR>\15<Leader>mn\6n\20nvim_set_keymap\bapi\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/memolist.vim",
    url = "https://github.com/glidenote/memolist.vim"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\n;\0\1\4\0\4\0\0066\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\20vsnip#anonymous\afn\bvimµ\3\1\0\n\0\28\00056\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0005\4\4\0003\5\3\0=\5\5\4=\4\a\0039\4\b\0009\4\t\0049\4\n\0045\6\f\0009\a\b\0009\a\v\a)\tüÿB\a\2\2=\a\r\0069\a\b\0009\a\v\a)\t\4\0B\a\2\2=\a\14\0069\a\b\0009\a\15\aB\a\1\2=\a\16\0069\a\b\0009\a\17\aB\a\1\2=\a\18\0069\a\b\0009\a\19\a5\t\20\0B\a\2\2=\a\21\6B\4\2\2=\4\b\0039\4\22\0009\4\23\0044\6\5\0005\a\24\0>\a\1\0065\a\25\0>\a\2\0065\a\26\0>\a\3\0065\a\27\0>\a\4\6B\4\2\2=\4\23\3B\1\2\1K\0\1\0\1\0\1\tname\nvsnip\1\0\1\tname\tpath\1\0\1\tname\vbuffer\1\0\1\tname\rnvim_lsp\fsources\vconfig\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\nabort\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\bcmp\frequire\0" },
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n‡\a\0\2\t\0\25\0R5\2\0\0006\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\5\0'\a\6\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\a\0'\a\b\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\t\0'\a\n\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\v\0'\a\f\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\r\0'\a\14\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\15\0'\a\16\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\17\0'\a\18\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\19\0'\a\20\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\21\0'\a\22\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\23\0'\a\24\0\18\b\2\0B\3\5\1K\0\1\0&<cmd>lua vim.lsp.buf.rename()<CR>\15<Leader>rn6<cmd>lua vim.lsp.buf.format({ async = true })<CR>\16<Leader>fmtG<cmd>lua vim.lsp.buf.references({ includeDeclaration = true })<CR>\16<Leader>grf/<cmd>lua vim.lsp.buf.type_definition()<CR>\15<Leader>gt.<cmd>lua vim.lsp.buf.implementation()<CR>\15<Leader>gi/<cmd>lua vim.lsp.buf.document_symbol()<CR>\16<Leader>gdc'<cmd>lua vim.lsp.buf.declaration()\16<Leader>gde%<cmd>lua vim.lsp.buf.hover()<CR>\6K.<cmd>lua vim.lsp.buf.signature_help()<CR>\n<c-k>*<cmd>lua vim.lsp.buf.definition()<CR>\n<c-]>\6n\20nvim_set_keymap\bapi\bvim\1\0\2\fnoremap\2\vsilent\2Ñ\14\1\0\14\0A\0¦\0016\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0026\1\3\0009\1\4\0019\1\5\0013\2\6\0005\3\a\0006\4\0\0'\6\b\0B\4\2\0029\4\t\0049\4\n\0045\6\v\0=\2\f\6=\3\r\6=\0\14\0065\a\15\0=\a\16\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\17\0049\4\n\0045\6\18\0=\2\f\6=\3\r\6=\0\14\0065\a\19\0004\b\0\0=\b\20\a=\a\21\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\22\0049\4\n\0045\6\23\0=\2\f\6=\3\r\6=\0\14\0065\a\24\0=\a\25\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\26\0049\4\n\0045\6\27\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\28\0049\4\n\0045\6\29\0=\2\f\6=\3\r\6=\0\14\0065\a\31\0\18\b\1\0'\n\30\0B\b\2\2>\b\1\a\18\b\1\0'\n \0B\b\2\2'\t!\0&\b\t\b>\b\3\a=\a\16\0065\a/\0005\b%\0005\t#\0005\n\"\0=\n$\t=\t&\b5\t*\0006\n\3\0009\n'\n9\n(\n'\f)\0+\r\2\0B\n\3\2=\n+\t=\t,\b5\t-\0=\t.\b=\b0\a=\a\21\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0041\0049\4\n\0045\0062\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\26\0049\4\n\0045\0063\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0044\0049\4\n\0045\0065\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0046\0049\4\n\0045\0067\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0048\0049\4\n\0045\0069\0=\2\f\6=\3\r\6=\0\14\0065\a=\0005\b;\0005\t:\0=\t<\b=\b>\a=\a\21\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4?\0049\4\n\0045\6@\0=\2\f\6=\3\r\6=\0\14\6B\4\2\1K\0\1\0\1\0\0\16terraformls\tyaml\1\0\0\fschemas\1\0\0\1\0\b+http://json.schemastore.org/prettierrc\27.prettierrc.{yml,yaml},http://json.schemastore.org/stylelintrc\28.stylelintrc.{yml,yaml}3http://json.schemastore.org/ansible-stable-2.9\29roles/tasks/*.{yml,yaml}/http://json.schemastore.org/circleciconfig\30.circleci/**/*.{yml,yaml}.http://json.schemastore.org/github-action\30.github/action.{yml,yaml}/https://json.schemastore.org/kustomization\29kustomization.{yml,yaml}0http://json.schemastore.org/github-workflow#.github/workflows/*.{yml,yaml},https://json.schemastore.org/cloudbuild\27*cloudbuild.{yml,yaml}\1\0\0\vyamlls\1\0\0\vjsonls\1\0\0\fpyright\1\0\0\1\0\0\rtsserver\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\5\26nvim_get_runtime_file\bapi\16diagnostics\1\0\0\vglobal\1\0\0\1\2\0\0\bvim\14/main.lua\16LUA_LSP_DIR\1\3\0\0\0\a-E\16LUA_LSP_BIN\1\0\0\16sumneko_lua\1\0\0\15solargraph\17init_options\1\0\a\20usePlaceholders\2\18symbolMatcher\18CaseSensitive\fmatcher\18CaseSensitive\19deepCompletion\2\23completeUnimported\2\28completionDocumentation\2\15linkTarget\15pkg.go.dev\1\0\0\ngopls\rsettings\18rust-analyzer\1\0\0\1\0\0\18rust_analyzer\bcmd\1\3\0\0\vclangd\23--background-index\17capabilities\nflags\14on_attach\1\0\0\nsetup\vclangd\14lspconfig\1\0\1\26debounce_text_changes\3–\1\0\14os_getenv\tloop\bvim\25default_capabilities\17cmp_nvim_lsp\frequire\0" },
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-luadev"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/nvim-luadev",
    url = "https://github.com/bfredl/nvim-luadev"
  },
  ["open-browser-github.vim"] = {
    commands = { "OpenGithubFile", "OpenGithubIssue", "OpenGithubPullReq" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/open-browser-github.vim",
    url = "https://github.com/tyru/open-browser-github.vim"
  },
  ["open-browser.vim"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/open-browser.vim",
    url = "https://github.com/tyru/open-browser.vim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  rainbow_csv = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/rainbow_csv",
    url = "https://github.com/mechatroner/rainbow_csv"
  },
  ["rust-doc.vim"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/rust-doc.vim",
    url = "https://github.com/rhysd/rust-doc.vim"
  },
  ["startuptime.vim"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/startuptime.vim",
    url = "https://github.com/tweekmonster/startuptime.vim"
  },
  tagbar = {
    commands = { "TabbarToggle", "TagbarOpen" },
    config = { "\27LJ\2\nv\0\0\6\0\a\0\t6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\1K\0\1\0\1\0\2\fnoremap\2\vsilent\2\22:TagbarToggle<CR>\15<Leader>tb\6n\20nvim_set_keymap\bapi\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/tagbar",
    url = "https://github.com/preservim/tagbar"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "https://github.com/tpope/vim-commentary"
  },
  ["vim-endwise"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/vim-endwise",
    url = "https://github.com/tpope/vim-endwise"
  },
  ["vim-goaddtags"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/vim-goaddtags",
    url = "https://github.com/mattn/vim-goaddtags"
  },
  ["vim-goimports"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/vim-goimports",
    url = "https://github.com/mattn/vim-goimports"
  },
  ["vim-gorename"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/vim-gorename",
    url = "https://github.com/mattn/vim-gorename"
  },
  ["vim-polyglot"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/vim-polyglot",
    url = "https://github.com/sheerun/vim-polyglot"
  },
  ["vim-vsnip"] = {
    loaded = true,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/start/vim-vsnip",
    url = "https://github.com/hrsh7th/vim-vsnip"
  },
  ["vinarise.vim"] = {
    commands = { "Vinarise" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/hatahirokazu/.local/share/nvim/site/pack/packer/opt/vinarise.vim",
    url = "https://github.com/Shougo/vinarise.vim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\nö\5\0\0\6\0%\00096\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0004\5\0\0=\5\t\0044\5\0\0=\5\n\4=\4\v\0035\4\f\0=\4\r\3=\3\15\0025\3\17\0005\4\16\0=\4\18\0035\4\19\0=\4\20\0035\4\21\0=\4\22\0035\4\23\0=\4\24\0035\4\25\0=\4\26\0035\4\27\0=\4\28\3=\3\29\0025\3\30\0004\4\0\0=\4\18\0034\4\0\0=\4\20\0035\4\31\0=\4\22\0035\4 \0=\4\24\0034\4\0\0=\4\26\0034\4\0\0=\4\28\3=\3!\0024\3\0\0=\3\"\0024\3\0\0=\3\n\0024\3\0\0=\3#\0024\3\0\0=\3$\2B\0\2\1K\0\1\0\15extensions\20inactive_winbar\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\rsections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\4\0\0\rencoding\15fileformat\rfiletype\14lualine_c\1\2\0\0\rfilename\14lualine_b\1\4\0\0\vbranch\tdiff\16diagnostics\14lualine_a\1\0\0\1\2\0\0\tmode\foptions\1\0\0\frefresh\1\0\3\vwinbar\3è\a\ftabline\3è\a\15statusline\3è\a\23disabled_filetypes\vwinbar\15statusline\1\0\0\23section_separators\1\0\2\tleft\6|\nright\6|\25component_separators\1\0\2\tleft\6|\nright\6|\1\0\4\17globalstatus\1\25always_divide_middle\2\ntheme\tauto\18icons_enabled\1\nsetup\flualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: jellybeans.vim
time([[Config for jellybeans.vim]], true)
try_loadstring("\27LJ\2\no\0\0\3\0\a\0\n6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\4\0009\0\5\0'\2\6\0B\0\2\1K\0\1\0\27colorscheme jellybeans\17nvim_command\bapi\tdark\15background\bopt\bvim\0", "config", "jellybeans.vim")
time([[Config for jellybeans.vim]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\n;\0\1\4\0\4\0\0066\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\20vsnip#anonymous\afn\bvimµ\3\1\0\n\0\28\00056\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0005\4\4\0003\5\3\0=\5\5\4=\4\a\0039\4\b\0009\4\t\0049\4\n\0045\6\f\0009\a\b\0009\a\v\a)\tüÿB\a\2\2=\a\r\0069\a\b\0009\a\v\a)\t\4\0B\a\2\2=\a\14\0069\a\b\0009\a\15\aB\a\1\2=\a\16\0069\a\b\0009\a\17\aB\a\1\2=\a\18\0069\a\b\0009\a\19\a5\t\20\0B\a\2\2=\a\21\6B\4\2\2=\4\b\0039\4\22\0009\4\23\0044\6\5\0005\a\24\0>\a\1\0065\a\25\0>\a\2\0065\a\26\0>\a\3\0065\a\27\0>\a\4\6B\4\2\2=\4\23\3B\1\2\1K\0\1\0\1\0\1\tname\nvsnip\1\0\1\tname\tpath\1\0\1\tname\vbuffer\1\0\1\tname\rnvim_lsp\fsources\vconfig\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\nabort\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\bcmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n‡\a\0\2\t\0\25\0R5\2\0\0006\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\5\0'\a\6\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\a\0'\a\b\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\t\0'\a\n\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\v\0'\a\f\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\r\0'\a\14\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\15\0'\a\16\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\17\0'\a\18\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\19\0'\a\20\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\21\0'\a\22\0\18\b\2\0B\3\5\0016\3\1\0009\3\2\0039\3\3\3'\5\4\0'\6\23\0'\a\24\0\18\b\2\0B\3\5\1K\0\1\0&<cmd>lua vim.lsp.buf.rename()<CR>\15<Leader>rn6<cmd>lua vim.lsp.buf.format({ async = true })<CR>\16<Leader>fmtG<cmd>lua vim.lsp.buf.references({ includeDeclaration = true })<CR>\16<Leader>grf/<cmd>lua vim.lsp.buf.type_definition()<CR>\15<Leader>gt.<cmd>lua vim.lsp.buf.implementation()<CR>\15<Leader>gi/<cmd>lua vim.lsp.buf.document_symbol()<CR>\16<Leader>gdc'<cmd>lua vim.lsp.buf.declaration()\16<Leader>gde%<cmd>lua vim.lsp.buf.hover()<CR>\6K.<cmd>lua vim.lsp.buf.signature_help()<CR>\n<c-k>*<cmd>lua vim.lsp.buf.definition()<CR>\n<c-]>\6n\20nvim_set_keymap\bapi\bvim\1\0\2\fnoremap\2\vsilent\2Ñ\14\1\0\14\0A\0¦\0016\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0026\1\3\0009\1\4\0019\1\5\0013\2\6\0005\3\a\0006\4\0\0'\6\b\0B\4\2\0029\4\t\0049\4\n\0045\6\v\0=\2\f\6=\3\r\6=\0\14\0065\a\15\0=\a\16\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\17\0049\4\n\0045\6\18\0=\2\f\6=\3\r\6=\0\14\0065\a\19\0004\b\0\0=\b\20\a=\a\21\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\22\0049\4\n\0045\6\23\0=\2\f\6=\3\r\6=\0\14\0065\a\24\0=\a\25\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\26\0049\4\n\0045\6\27\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\28\0049\4\n\0045\6\29\0=\2\f\6=\3\r\6=\0\14\0065\a\31\0\18\b\1\0'\n\30\0B\b\2\2>\b\1\a\18\b\1\0'\n \0B\b\2\2'\t!\0&\b\t\b>\b\3\a=\a\16\0065\a/\0005\b%\0005\t#\0005\n\"\0=\n$\t=\t&\b5\t*\0006\n\3\0009\n'\n9\n(\n'\f)\0+\r\2\0B\n\3\2=\n+\t=\t,\b5\t-\0=\t.\b=\b0\a=\a\21\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0041\0049\4\n\0045\0062\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4\26\0049\4\n\0045\0063\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0044\0049\4\n\0045\0065\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0046\0049\4\n\0045\0067\0=\2\f\6=\3\r\6=\0\14\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\0048\0049\4\n\0045\0069\0=\2\f\6=\3\r\6=\0\14\0065\a=\0005\b;\0005\t:\0=\t<\b=\b>\a=\a\21\6B\4\2\0016\4\0\0'\6\b\0B\4\2\0029\4?\0049\4\n\0045\6@\0=\2\f\6=\3\r\6=\0\14\6B\4\2\1K\0\1\0\1\0\0\16terraformls\tyaml\1\0\0\fschemas\1\0\0\1\0\b+http://json.schemastore.org/prettierrc\27.prettierrc.{yml,yaml},http://json.schemastore.org/stylelintrc\28.stylelintrc.{yml,yaml}3http://json.schemastore.org/ansible-stable-2.9\29roles/tasks/*.{yml,yaml}/http://json.schemastore.org/circleciconfig\30.circleci/**/*.{yml,yaml}.http://json.schemastore.org/github-action\30.github/action.{yml,yaml}/https://json.schemastore.org/kustomization\29kustomization.{yml,yaml}0http://json.schemastore.org/github-workflow#.github/workflows/*.{yml,yaml},https://json.schemastore.org/cloudbuild\27*cloudbuild.{yml,yaml}\1\0\0\vyamlls\1\0\0\vjsonls\1\0\0\fpyright\1\0\0\1\0\0\rtsserver\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\5\26nvim_get_runtime_file\bapi\16diagnostics\1\0\0\vglobal\1\0\0\1\2\0\0\bvim\14/main.lua\16LUA_LSP_DIR\1\3\0\0\0\a-E\16LUA_LSP_BIN\1\0\0\16sumneko_lua\1\0\0\15solargraph\17init_options\1\0\a\20usePlaceholders\2\18symbolMatcher\18CaseSensitive\fmatcher\18CaseSensitive\19deepCompletion\2\23completeUnimported\2\28completionDocumentation\2\15linkTarget\15pkg.go.dev\1\0\0\ngopls\rsettings\18rust-analyzer\1\0\0\1\0\0\18rust_analyzer\bcmd\1\3\0\0\vclangd\23--background-index\17capabilities\nflags\14on_attach\1\0\0\nsetup\vclangd\14lspconfig\1\0\1\26debounce_text_changes\3–\1\0\14os_getenv\tloop\bvim\25default_capabilities\17cmp_nvim_lsp\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: fzf-lua
time([[Config for fzf-lua]], true)
try_loadstring("\27LJ\2\nƒ\1\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0B\1\2\1K\0\1\0\1\0\1\frg_optsD--column --line-number --no-heading --color=always --smart-case\tgrep\ffzf-lua\frequireƒ\1\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0B\1\2\1K\0\1\0\1\0\1\frg_optsD--column --line-number --no-heading --color=always --smart-case\tgrep\ffzf-lua\frequirel\0\1\a\0\t\0\r6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\a\0006\4\3\0009\4\4\0049\4\5\4'\6\6\0B\4\2\2=\4\b\3B\1\2\1K\0\1\0\bcwd\1\0\0\n%:p:h\vexpand\afn\bvim\nfiles\ffzf-lua\frequireb\0\1\6\0\b\0\f6\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\6\0006\4\3\0009\4\4\0049\4\5\4B\4\1\2=\4\a\3B\1\2\1K\0\1\0\bcwd\1\0\0\vgetcwd\afn\bvim\nfiles\ffzf-lua\frequireÔ\a\1\0\a\0$\0a6\0\0\0009\0\1\0009\1\2\0'\3\3\0003\4\4\0005\5\5\0B\1\4\0019\1\2\0'\3\6\0003\4\a\0005\5\b\0B\1\4\0019\1\2\0'\3\t\0003\4\n\0005\5\v\0B\1\4\0019\1\2\0'\3\f\0003\4\r\0005\5\14\0B\1\4\0015\1\15\0007\1\16\0006\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\19\0'\5\20\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\21\0'\5\22\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\23\0'\5\24\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\25\0'\5\26\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\27\0'\5\28\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\29\0'\5\28\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\30\0'\5\31\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4 \0'\5!\0006\6\16\0B\1\5\0016\1\0\0009\1\1\0019\1\17\1'\3\18\0'\4\"\0'\5#\0006\6\16\0B\1\5\1K\0\1\0+<cmd>lua require('fzf-lua').tags()<CR>\14<Leader>t,<cmd>lua require('fzf-lua').files()<CR>\14<Leader>f.<cmd>lua require('fzf-lua').buffers()<CR>\14<Leader>b\15<Leader>gr\r:Rg <CR>\15<Leader>rg\21:ProjectDir <CR>\15<Leader>pd\27:CurrentBufferDir <CR>\16<Leader>cbd1<cmd>lua require('fzf-lua').grep_cword()<CR>\15<Leader>cw^<cmd>lua require('fzf-lua').blines({ winopts = { preview = { hidden = 'hidden' } } })<CR>\6/\6n\20nvim_set_keymap\bopt\1\0\2\fnoremap\2\vsilent\2\1\0\2\tbang\2\nnargs\6?\0\15ProjectDir\1\0\2\tbang\2\nnargs\6?\0\21CurrentBufferDir\1\0\2\tbang\2\nnargs\6*\0\18CurrentWordRg\1\0\2\tbang\2\nnargs\6*\0\aRg\29nvim_create_user_command\bapi\bvim\0", "config", "fzf-lua")
time([[Config for fzf-lua]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TabbarToggle lua require("packer.load")({'tagbar'}, { cmd = "TabbarToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TagbarOpen lua require("packer.load")({'tagbar'}, { cmd = "TagbarOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file OpenGithubPullReq lua require("packer.load")({'open-browser-github.vim'}, { cmd = "OpenGithubPullReq", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file MemoNew lua require("packer.load")({'memolist.vim'}, { cmd = "MemoNew", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file MemoList lua require("packer.load")({'memolist.vim'}, { cmd = "MemoList", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GitMessengerClose lua require("packer.load")({'git-messenger.vim'}, { cmd = "GitMessengerClose", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'startuptime.vim'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Vinarise lua require("packer.load")({'vinarise.vim'}, { cmd = "Vinarise", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file OpenGithubIssue lua require("packer.load")({'open-browser-github.vim'}, { cmd = "OpenGithubIssue", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file OpenGithubFile lua require("packer.load")({'open-browser-github.vim'}, { cmd = "OpenGithubFile", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file MemoGrep lua require("packer.load")({'memolist.vim'}, { cmd = "MemoGrep", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GitMessenger lua require("packer.load")({'git-messenger.vim'}, { cmd = "GitMessenger", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType help ++once lua require("packer.load")({'rust-doc.vim'}, { ft = "help" }, _G.packer_plugins)]]
vim.cmd [[au FileType ruby ++once lua require("packer.load")({'vim-endwise'}, { ft = "ruby" }, _G.packer_plugins)]]
vim.cmd [[au FileType gomod ++once lua require("packer.load")({'vim-gorename', 'vim-goimports', 'vim-goaddtags'}, { ft = "gomod" }, _G.packer_plugins)]]
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-gorename', 'vim-goimports', 'vim-goaddtags'}, { ft = "go" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end

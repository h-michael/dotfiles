local is_vs_code = vim.g.vscode

if not is_vs_code then
  require("config.lazy")
end

require('option')
require('keymap')
require('vim_extension')
require('autocmd')

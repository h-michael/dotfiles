local api = vim.api

api.nvim_create_augroup('MyAutoGroup', {})
api.nvim_create_autocmd(
  'WinEnter',
  {
    pattern = '*',
    group = 'MyAutoGroup',
    callback = function() vim.cmd [[ checktime ]] end,
  }
)

api.nvim_create_augroup('AutoMkDir', {})
api.nvim_create_autocmd(
  'BufWritePre',
  {
    pattern = '*',
    group = 'AutoMkDir',
    desc = "Create new directories if directories doesn't exist",
    callback = function()
      -- http://vim-users.jp/2011/02/hack202/
      local mk_dir_if_not_exist = function(dir)
        if not (vim.fn.isdirectory(dir)) and vim.bo.buftype == "" and string.match(vim.fn.input(vim.fn.printf('"%s" does not exist. Create? [y/N]', dir)), '^y$') then
          vim.fn.mkdir(vim.fn.iconv(dir, vim.opt.encoding:get(), vim.g.termencoding), 'p')
        end
      end
      mk_dir_if_not_exist(vim.fn.expand('<afile>:p:h'))
    end,
  }
)

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("autoupdate"),
  callback = function()
    if require("lazy.status").has_updates then
      require("lazy").update({ show = false, })
    end
  end,
})

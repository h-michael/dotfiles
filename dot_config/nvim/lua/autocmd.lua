local api = vim.api

api.nvim_create_augroup('MyAutoGroup', {})
api.nvim_create_autocmd('WinEnter', {
  pattern = '*',
  group = 'MyAutoGroup',
  callback = function()
    vim.cmd([[ checktime ]])
  end,
})

api.nvim_create_augroup('AutoMkDir', {})
api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  group = 'AutoMkDir',
  desc = "Create new directories if directories doesn't exist",
  callback = function()
    -- http://vim-users.jp/2011/02/hack202/
    local mk_dir_if_not_exist = function(dir)
      if
        not (vim.fn.isdirectory(dir))
        and vim.bo.buftype == ''
        and string.match(vim.fn.input(vim.fn.printf('"%s" does not exist. Create? [y/N]', dir)), '^y$')
      then
        vim.fn.mkdir(vim.fn.iconv(dir, vim.opt.encoding:get(), vim.g.termencoding), 'p')
      end
    end
    mk_dir_if_not_exist(vim.fn.expand('<afile>:p:h'))
  end,
})

local function augroup(name)
  return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd('VimEnter', {
  group = augroup('autoupdate'),
  callback = function()
    if require('lazy.status').has_updates then
      require('lazy').update({ show = false })
    end
  end,
})

api.nvim_create_augroup('CargoTomlKeymaps', { clear = true })
api.nvim_create_autocmd('BufEnter', {
  group = 'CargoTomlKeymaps',
  pattern = 'Cargo.toml',
  callback = function()
    local bufnr = api.nvim_get_current_buf()
    local crates = require('crates')
    local wk = require('which-key')

    wk.add({
      { '<Leader>c', buffer = bufnr, group = 'Cargo' },
      { '<leader>cr', crates.reload, desc = 'Reload', buffer = bufnr },
      { '<leader>ct', crates.toggle, desc = 'Toggle', buffer = bufnr },
      { '<leader>cv', crates.show_versions_popup, desc = 'Show versions', buffer = bufnr },
      { '<leader>cf', crates.show_features_popup, desc = 'Show features', buffer = bufnr },
      { '<leader>cd', crates.show_dependencies_popup, desc = 'Show dependencies', buffer = bufnr },
      { '<leader>cus', crates.update_crate, desc = 'Update single crate', buffer = bufnr },
      { '<leader>cum', crates.update_crates, desc = 'Update multiple crates', buffer = bufnr },
      { '<leader>ca', crates.update_all_crates, desc = 'Update all crates', buffer = bufnr },
      { '<leader>cUs', crates.upgrade_crate, desc = 'Upgrade single crate', buffer = bufnr },
      { '<leader>cUm', crates.upgrade_crates, desc = 'Upgrade multiple crates', buffer = bufnr },
      { '<leader>cA', crates.upgrade_all_crates, desc = 'Upgrade all crates', buffer = bufnr },
      {
        '<leader>cx',
        crates.expand_plain_crate_to_inline_table,
        desc = 'Expand a plain crate declaration into an inline table',
        buffer = bufnr,
      },
      {
        '<leader>cX',
        crates.extract_crate_into_table,
        desc = 'Extract an crate declaration from a dependency section into a table',
        buffer = bufnr,
      },
      { '<leader>cH', crates.open_homepage, desc = 'Open homepage', buffer = bufnr },
      { '<leader>cR', crates.open_repository, desc = 'Open repository', buffer = bufnr },
      { '<leader>cD', crates.open_documentation, desc = 'Open documentation', buffer = bufnr },
      { '<leader>cC', crates.open_crates_io, desc = 'Open crates.io', buffer = bufnr },
    })
  end,
})

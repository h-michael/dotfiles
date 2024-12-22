local api = vim.api

--vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':<C-u>nohlsearch<CR>:<C-u>call <SID>hier_clear()<CR>', { noremap = true, silent = true })
--vim.api.nvim_set_keymap('', '<leader>ss', ':setlocal', 'spell!' '<CR>')

-- yank the word which is under cursor
api.nvim_set_keymap('n', 'yc', 'vawy', {})

-- in insert mode moving key maps
api.nvim_set_keymap('i', '<C-e>', '<END>', { noremap = true })
api.nvim_set_keymap('i', '<C-a>', '<HOME>', { noremap = true })
api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true })
api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true })
api.nvim_set_keymap('i', '<C-h>', '<Left>', { noremap = true })
api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true })
api.nvim_set_keymap('n', '<C-l>', ':<C-u>tabnext<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<C-h>', ':<C-u>tabprevious<CR>', { noremap = true, silent = true })

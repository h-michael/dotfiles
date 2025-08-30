local bufnr = vim.api.nvim_get_current_buf()

local wk = require("which-key")
wk.add({
  { "K", "<cmd>lua vim.cmd.RustLsp {'hover', 'actions'}<CR>", desc = "Hover Actions", buffer = bufnr, remap = false },
  { "<Leader>la", "<cmd>lua vim.cmd.RustLsp('codeAction')<CR>", desc = "Code Action", buffer = bufnr, remap = false },
  { "<Leader>lem", "<cmd>lua vim.cmd.RustLsp('expandMacro')<CR>", desc = "Expand macros recursively", buffer = bufnr, remap = false },
  { "<Leader>lrm", "<cmd>lua vim.cmd.RustLsp('rebuildProcMacros')<CR>", desc = "Rebuild proc macro", buffer = bufnr, remap = false },
  { "<Leader>lmu", "<cmd>lua vim.cmd.RustLsp {'moveItem', 'up'}<CR>", desc = "Move item up", buffer = bufnr, remap = false },
  { "<Leader>lmd", "<cmd>lua vim.cmd.RustLsp {'moveItem', 'down'}<CR>", desc = "Move item down", buffer = bufnr, remap = false },
  { "<Leader>lee", "<cmd>lua vim.cmd.RustLsp('explainError')<CR>", desc = "Explain error", buffer = bufnr, remap = false },
  { "<Leader>lrd", "<cmd>lua vim.cmd.RustLsp('renderDiagnostic')<CR>", desc = "Render diagnostics", buffer = bufnr, remap = false },
  { "<Leader>ljd", "<cmd>lua vim.cmd.RustLsp('relatedDiagnostics')<CR>", desc = "Jump to related diagnostics", buffer = bufnr, remap = false },
  { "<Leader>loc", "<cmd>lua vim.cmd.RustLsp('openCargo')<CR>", desc = "Open Cargo.toml", buffer = bufnr, remap = false },
  { "<Leader>lod", "<cmd>lua vim.cmd.RustLsp('openDocs')<CR>", desc = "Open docs.rs", buffer = bufnr, remap = false },
  { "<Leader>lpm", "<cmd>lua vim.cmd.RustLsp('parentModule')<CR>", desc = "Parent module", buffer = bufnr, remap = false },
  { "<Leader>lcg", "<cmd>lua vim.cmd.RustLsp {'crateGraph', '[backend]', '[output]'}<CR>", desc = "Crate graph", buffer = bufnr, remap = false },
  { "<Leader>lst", "<cmd>lua vim.cmd.RustLsp('syntaxTree')<CR>", desc = "View syntax tree", buffer = bufnr, remap = false },
})

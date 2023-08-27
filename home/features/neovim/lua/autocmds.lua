local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  pattern = "*",
  nested = true,
  command = "colorscheme iceberg",
})

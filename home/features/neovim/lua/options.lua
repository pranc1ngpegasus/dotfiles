local options = {
  ambiwidth = 'double',
  autoread = true,
  background = 'dark',
  clipboard = 'unnamed',
  cursorcolumn = true,
  cursorline = true,
  encoding = 'UTF-8',
  expandtab = true,
  ignorecase = true,
  inccommand = 'split',
  incsearch = true,
  laststatus = 3,
  backup = false,
  showmode = false,
  swapfile = false,
  number = true,
  scrolloff = 1000,
  sh = 'fish',
  shiftround = true,
  shiftwidth = 2,
  smartcase = true,
  smartindent = true,
  tabstop = 2,
  termguicolors = true,
  title = true,
  wrapscan = true,
}

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

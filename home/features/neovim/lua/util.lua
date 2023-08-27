-- netrw
vim.g.netrw_liststyle = 3
vim.g.netrw_preview = 1
vim.g.netrw_sizestyle = "H"
vim.g.netrw_timefmt = "%Y/%m/%d(%a) %H:%M:%S"

-- use ripgrep as vimgrep
vim.cmd([[
if executable('rg')
	set grepprg=rg\ --vimgrep\ --no-heading
	set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
]])

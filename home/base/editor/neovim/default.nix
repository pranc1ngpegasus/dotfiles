{pkgs, ...}: {
  imports = [
    ./plugins
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    initLua = ''
      -- options
      vim.opt.autoread = true
      vim.opt.background = "dark"
      vim.opt.clipboard = "unnamed"
      vim.opt.cmdheight = 0
      vim.opt.cursorcolumn = true
      vim.opt.cursorline = true
      vim.opt.encoding = "UTF-8"
      vim.opt.expandtab = true
      vim.opt.ignorecase = true
      vim.opt.inccommand = "split"
      vim.opt.incsearch = true
      vim.opt.laststatus = 0
      vim.opt.backup = false
      vim.opt.showmode = false
      vim.opt.swapfile = false
      vim.opt.number = true
      vim.opt.scrolloff = 1000
      vim.opt.shiftround = true
      vim.opt.shiftwidth = 2
      vim.opt.smartcase = true
      vim.opt.smartindent = true
      vim.opt.tabstop = 2
      vim.opt.termguicolors = true
      vim.opt.wrapscan = true

      -- netrw
      vim.g.netrw_liststyle = 3
      vim.g.netrw_preview = 1
      vim.g.netrw_sizestyle = "H"
      vim.g.netrw_timefmt = "%Y/%m/%d(%a) %H:%M:%S"

      -- disable unnecessary built-in plugins
      vim.g.did_indent_on             = 1
      vim.g.did_install_default_menus = 1
      vim.g.did_install_syntax_menu   = 1
      vim.g.did_load_ftplugin         = 1
      vim.g.loaded_2html_plugin       = 1
      vim.g.loaded_getscript          = 1
      vim.g.loaded_getscriptPlugin    = 1
      vim.g.loaded_gzip               = 1
      vim.g.loaded_man                = 1
      vim.g.loaded_matchit            = 1
      vim.g.loaded_matchparen         = 1
      vim.g.loaded_remote_plugins     = 1
      vim.g.loaded_rrhelper           = 1
      vim.g.loaded_shada_plugin       = 1
      vim.g.loaded_spellfile_plugin   = 1
      vim.g.loaded_sql_completion     = 1
      vim.g.loaded_tar                = 1
      vim.g.loaded_tarPlugin          = 1
      vim.g.loaded_tutor_mode_plugin  = 1
      vim.g.loaded_vimball            = 1
      vim.g.loaded_vimballPlugin      = 1
      vim.g.loaded_zip                = 1
      vim.g.loaded_zipPlugin          = 1
      vim.g.skip_loading_mswin        = 1
    '';
  };
}

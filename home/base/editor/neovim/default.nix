{ pkgs, ... }:
{
  imports = [
    ./plugins
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    withPython3 = false;
    withRuby = false;
    defaultEditor = true;
    initLua = ''
      pcall(function()
        vim.loader.enable()
      end)

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

      -- completion
      vim.o.pumborder = "rounded"
      vim.opt.completeopt = { "menu", "menuone", "noselect", "fuzzy", "popup" }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end,
      })

      -- workaround: add border to the documentation popup
      local orig_complete_set = vim.api.nvim__complete_set
      vim.api.nvim__complete_set = function(...)
        local result = orig_complete_set(...)
        if result and result.winid then
          pcall(vim.api.nvim_win_set_config, result.winid, { border = "rounded" })
        end
        return result
      end

      -- file explorer
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      local dir_view = {
        width = 36,
        winid = nil,
      }

      local function edit_dir(path)
        vim.api.nvim_cmd({ cmd = "edit", args = { path }, magic = { file = false, bar = false } }, {})
      end

      local function is_dir_view_window(win)
        if not vim.api.nvim_win_is_valid(win) then
          return false
        end
        local ok, value = pcall(vim.api.nvim_win_get_var, win, "nvim_dir_view")
        return ok and value == true
      end

      local function find_dir_view_window()
        if dir_view.winid and is_dir_view_window(dir_view.winid) then
          return dir_view.winid
        end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if is_dir_view_window(win) then
            dir_view.winid = win
            return win
          end
        end

        dir_view.winid = nil
        return nil
      end

      local function configure_dir_view_window(win)
        vim.api.nvim_win_set_var(win, "nvim_dir_view", true)
        vim.api.nvim_win_set_width(win, dir_view.width)
        vim.api.nvim_win_call(win, function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = "no"
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.statuscolumn = ""
          vim.opt_local.winfixwidth = true
          vim.opt_local.cursorline = true
        end)
      end

      local function select_dir_entry(name)
        if not name or name == "" then
          return
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for lnum, line in ipairs(lines) do
          if line == name or line == name .. "/" then
            vim.api.nvim_win_set_cursor(0, { lnum, 0 })
            return
          end
        end
      end

      local function open_dir_view(path, entry)
        local dir = vim.fs.normalize(vim.fs.abspath(path or vim.fn.getcwd()))
        local win = find_dir_view_window()

        if win then
          vim.api.nvim_set_current_win(win)
          edit_dir(dir)
          configure_dir_view_window(win)
          select_dir_entry(entry)
          return
        end

        vim.cmd("topleft vertical " .. dir_view.width .. "split")
        win = vim.api.nvim_get_current_win()
        dir_view.winid = win
        edit_dir(dir)
        configure_dir_view_window(win)
        select_dir_entry(entry)
      end

      local function current_path_parts()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          return vim.fn.getcwd(), nil
        end

        if vim.fn.isdirectory(path) == 1 then
          return path, nil
        end

        return vim.fs.dirname(path), vim.fs.basename(path)
      end

      local function toggle_dir_view()
        local win = find_dir_view_window()
        if win then
          if #vim.api.nvim_tabpage_list_wins(0) > 1 then
            vim.api.nvim_win_close(win, true)
          else
            vim.api.nvim_set_current_win(win)
            vim.cmd.enew()
          end
          dir_view.winid = nil
          return
        end

        open_dir_view(vim.fn.getcwd(), nil)
      end

      local function reveal_in_dir_view()
        local dir, entry = current_path_parts()
        open_dir_view(dir, entry)
      end

      vim.api.nvim_create_user_command("DirViewToggle", toggle_dir_view, {})
      vim.api.nvim_create_user_command("DirViewReveal", reveal_in_dir_view, {})
      vim.keymap.set("n", "<leader>e", toggle_dir_view, { noremap = true, silent = true, desc = "Toggle directory view" })
      vim.keymap.set("n", "<leader>E", reveal_in_dir_view, { noremap = true, silent = true, desc = "Reveal file in directory view" })

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

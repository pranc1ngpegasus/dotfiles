{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gopls
    nil
    rust-analyzer
    typescript-language-server
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = ''
        local servers = {"rust_analyzer", "gopls", "ts_ls", "nil_ls"};
        local opt = {
          on_attach = function(client, bufnr)
            local opts = { noremap = true, silent = true }
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gc', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'go', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.format({ async = false, timeout_ms = 1000 })'
          end,
          capabilities = require('blink-cmp').get_lsp_capabilities()
        }

        for _, server in ipairs(servers) do
          require('lspconfig')[server].setup(opt)
        end
      '';
    }
  ];
}

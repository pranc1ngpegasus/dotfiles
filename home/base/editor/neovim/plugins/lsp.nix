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
        local servers = {"rust_analyzer", "gopls", "ts_ls", "nil_ls"}

        local lsp_setup_group = vim.api.nvim_create_augroup("user_lsp_lazy_setup", { clear = true })
        vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
          group = lsp_setup_group,
          once = true,
          callback = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local blink_ok, blink = pcall(require, "blink-cmp")
            if blink_ok then
              capabilities = blink.get_lsp_capabilities(capabilities)
            end

            local format_group = vim.api.nvim_create_augroup("user_lsp_format_on_save", { clear = false })
            local opt = {
              on_attach = function(_, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set("n", "ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "gc", vim.lsp.buf.incoming_calls, opts)
                vim.keymap.set("n", "go", vim.lsp.buf.outgoing_calls, opts)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gf", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)

                vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = format_group,
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
                  end,
                })
              end,
              capabilities = capabilities,
            }

            local lspconfig = require("lspconfig")
            for _, server in ipairs(servers) do
              lspconfig[server].setup(opt)
            end
          end,
        })
      '';
    }
  ];
}

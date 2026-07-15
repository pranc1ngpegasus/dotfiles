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
        local format_group = vim.api.nvim_create_augroup("user_lsp_format_on_save", { clear = false })

        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client:supports_method("textDocument/completion") then
              vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
            end

            vim.api.nvim_clear_autocmds({ group = format_group, buffer = ev.buf })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = format_group,
              buffer = ev.buf,
              callback = function()
                vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
              end,
            })
          end,
        })

        for _, server in ipairs(servers) do
          vim.lsp.enable(server)
        end
      '';
    }
  ];
}

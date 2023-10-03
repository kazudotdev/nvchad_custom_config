return {
  { "williamboman/mason-lspconfig.nvim" },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" }
    },
    config = function ()
      local configs = require("plugins.configs.lspconfig")
      local lspconfig = require("lspconfig")
      require("mason-lspconfig").setup_handlers {
        function(server_name)
          lspconfig[server_name].setup {
            on_attach = configs.on_attach,
            capabilities = configs.capabilities,
          }
        end,
      }
    end,
  },
}

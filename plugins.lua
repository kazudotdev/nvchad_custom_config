return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          local mason_package = require "mason-core.package"
          local mason_registry = require "mason-registry"
          local null_ls = require "null-ls"
          local null_sources = {}

          for _, package in ipairs(mason_registry.get_installed_packages()) do
            local package_categories = package.spec.categories[1]
            if package_categories == mason_package.Cat.Formatter then
              table.insert(null_sources, null_ls.builtins.formatting[package.name])
            end
            if package_categories == mason_package.Cat.Linter then
              table.insert(null_sources, null_ls.builtins.diagnostics[package.name])
            end
          end
          null_ls.setup {
            debug = true,
            sources = null_sources,
          }
        end,
      },
    },
    config = function()
      local default_configs = require "plugins.configs.lspconfig"
      local lsp_config = require "lspconfig"
      require("mason-lspconfig").setup_handlers {
        function(server_name)
          lsp_config[server_name].setup {
            on_attach = default_configs.on_attach,
            capabilities = default_configs.capabilities,
          }
        end,
      }
    end,
  },
}

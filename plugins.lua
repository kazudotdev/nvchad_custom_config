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

      local function root_pattern_exclude(opt)
        local lspuil = lsp_config.util
        return function (fname)
          local excluded_root = lspuil.root_pattern(opt.exclude)(fname)
          local included_root = lspuil.root_pattern(opt.root)(fname)
          if excluded_root then
            return nil
          else
            return included_root
          end
        end
      end
      require("mason-lspconfig").setup_handlers {
        function(server_name)
          local setup_opts = {
            on_attach = default_configs.on_attach,
            capabilities = default_configs.capabilities,
          }
          if server_name == "denols" then
            setup_opts = {
              on_attach = default_configs.on_attach,
              capabilities = default_configs.capabilities,
              root_dir = lsp_config.util.root_pattern("deno.json"),
              init_options = {
                init = true,
                unstable = true,
                suggest = {
                  imports = {
                    hosts = {
                      ["https://deno.land"] = true,
                      ["https://cdn.nest.land"] = true,
                      ["https://crux.land"] = true,
                    },
                  },
                },
              },
            }
          elseif server_name == "tsserver" then
            setup_opts = {
              on_attach = default_configs.on_attach,
              capabilities = default_configs.capabilities,
              root_dir = root_pattern_exclude({
                root = { "package.json" },
                exclude = { "deno.json" },
              }),
              single_file_support = false,
            }
          end
          lsp_config[server_name].setup(setup_opts)
        end,
      }
    end,
  },
}

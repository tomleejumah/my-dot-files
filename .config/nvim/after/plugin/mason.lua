require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "rust_analyzer",
    "gopls",
    "lua_ls",
    "jdtls",
    "kotlin_language_server",
    "ruff",
    "clangd",
  },
  automatic_enable = {
    exclude = { "ts_ls", "intelephense", "pyright", "eslint", "html", "cssls", "emmet_ls" },
  },
})

for _, s in ipairs({ "ts_ls", "intelephense", "pyright", "eslint", "html", "cssls", "emmet_ls" }) do
  vim.lsp.enable(s)
end


--[[ require("mason-lspconfig").setup({
  ensure_installed = {
    "rust_analyzer",
    "gopls",                  --go programming
    "ts_ls",                  --JavaScript
    "lua_ls",                 --Lua
    "jdtls",                  -- Java
    "kotlin_language_server", -- Kotlin
    "intelephense",           -- PHP
    "pyright",                -- Python
    "ruff",                   --Python linter
    "clangd",                 -- C/C++
    "eslint",                 -- JavaScript/TypeScript linter
    "html",                   -- HTML
    "cssls",                  -- CSS
    "emmet_ls",               -- Emmet
  }
}) ]]

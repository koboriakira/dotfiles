-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require("null-ls")

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Set a formatter
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.phpcsfixer.with({
        command = "phpcsfixer", -- コマンド名はMasonがインストールした名前と一致する
        args = { "fix", "--using-cache=no", "--no-interaction", "--quiet", "$FILENAME" },
      }),
    })
  end,
}

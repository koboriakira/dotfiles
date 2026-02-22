-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

-- 相対パスをクリップボードにコピーする
vim.api.nvim_create_user_command("Cppath", function()
  local path = vim.fn.expand "%:p:."
  vim.fn.setreg("+", path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

-- いま開いているファイルを実行する
local last_run_cmd = nil

vim.api.nvim_create_user_command("Run", function()
  -- 現在のファイルタイプを取得
  local filetype = vim.bo.filetype

  if filetype == "python" then
    local relative_path = vim.fn.expand "%:p:."
    local module_name = relative_path:gsub("%.py$", ""):gsub("/", ".")

    local cmd = "python -m " .. module_name
    vim.notify("Running: " .. cmd, vim.log.levels.INFO) -- 実行するコマンドを通知する
    vim.cmd("split | terminal " .. cmd .. " && exit") -- Neovimのターミナルでコマンドを実行し、正常終了したらターミナルを閉じる

    last_run_cmd = cmd -- コマンドを保存する
  else
    -- ファイルタイプがPython以外の場合の通知
    vim.notify('The "Run" command only works for the specified files.', vim.log.levels.WARN)
  end
end, {})

-- 最後に実行したコマンドを繰り返し実行する
vim.api.nvim_create_user_command("RepeatRun", function()
  if last_run_cmd then
    vim.notify("Repeating: " .. last_run_cmd, vim.log.levels.INFO) -- 実行するコマンドを通知する
    vim.cmd("split | terminal " .. last_run_cmd .. " && exit") -- Neovimのターミナルでコマンドを実行し、正常終了したらターミナルを閉じる
  else
    vim.notify("No command to repeat.", vim.log.levels.WARN)
  end
end, {})

-- 社内用のPHPUnitの実行コマンド
vim.api.nvim_create_user_command("CodmonPhpunit", function()
  local relative_path = vim.fn.expand "%:p:."

  -- foo/bar/Hoge.phpファイルをfoo/bar/HogeTest.phpに変換する
  -- もし`Hoge.class.php`のようなファイル名だった場合は、`HogeTest.php`に変換する
  local test_filepath
  if relative_path:match "class%.php$" then
    test_filepath = relative_path:gsub(".class.php$", "Test.php")
  else
    test_filepath = relative_path:gsub(".php$", "Test.php")
  end

  vim.o.makeprg = "docker exec -w /var/www/html/www.codmon.com manager ./sys/lib/composer/vendor/bin/phpunit test/phpunit/"
    .. test_filepath
  vim.cmd "make"
  vim.cmd "copen"
end, { nargs = "*" })

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },

  {
    "github/copilot.vim",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      vim.g.copilot_no_tab_map = true

      local keymap = vim.keymap.set
      -- https://github.com/orgs/community/discussions/29817#discussioncomment-4217615
      keymap(
        "i",
        "<C-g>",
        'copilot#Accept("<CR>")',
        { silent = true, expr = true, script = true, replace_keycodes = false }
      )
      keymap("i", "<C-j>", "<Plug>(copilot-next)")
      keymap("i", "<C-k>", "<Plug>(copilot-previous)")
      keymap("i", "<C-o>", "<Plug>(copilot-dismiss)")
      keymap("i", "<C-s>", "<Plug>(copilot-suggest)")
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
}

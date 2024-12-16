-- 開いたディレクトリに.venvがあればパスを通す
-- refs: https://zenn.dev/misora/articles/d0e8c244f2f4db
local function auto_activate_venv()
  -- `..`は文字列の連結演算子
  local venv_path = vim.fn.getcwd() .. '/.venv'
  if vim.fn.isdirectory(venv_path) == 1 then
    -- 環境変数としてVIRTUAL_ENVとPATHを設定
    vim.env.VIRTUAL_ENV = venv_path
    vim.env.PATH = venv_path .. '/bin:' .. vim.env.PATH
  end
end

-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

-- NeoVimを起動したときに自動で仮想環境を有効にする
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    auto_activate_venv()
  end
})

-- Pytestコマンドを追加
vim.api.nvim_create_user_command('Pytest', function(opts)
  -- 簡潔なtracebackに。また色なしにすることで、quickfixの機能(エラー箇所にジャンプ)を使えるようにする
  vim.o.makeprg = 'pytest --tb=short --color=no '
  -- フォーマット: ファイル名:行番号:列番号: エラーメッセージ または ファイル名:行番号: エラーメッセージ
  vim.o.errorformat = '%A%f:%l:%c: %m,%A%f:%l: %m,%Z%.%#'
  -- makeコマンドを実行する。makeprgに設定した上述のコマンドを実行して、エラー箇所をquickfixリストに追加する
  vim.cmd('make ' .. opts.args)
  -- quickfixウィンドウを開く
  vim.cmd('copen')
end, { nargs = '*' })

require "lazy_setup"
require "polish"

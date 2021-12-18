" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" LSP連携・補完機能・VSCodeからPortingした各種extensionsによる設定の簡易さを全て兼ね備えているAll in Oneのプラグインです。
" coc.nvimを導入するとVimからVSCodeの機能の大半が使えるようになります。
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Initialize plugin system
call plug#end()

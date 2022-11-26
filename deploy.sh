#!/bin/bash
DOTPATH=$HOME/.dotfiles
cd ${DOTPATH}

for f in .??*
do
    # ドットから始まるディレクトリのうち、
    # .config, .ssh, .zshをシンボリックリンク対象にする
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".gitignore" ]] && continue
    [[ "$f" == ".devcontainer" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue

    echo $f
    ln -snfv ${DOTPATH}/${f} ${HOME}/${f}
done

echo $(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)

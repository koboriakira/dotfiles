#!/bin/bash
DOTPATH=$HOME/.dotfiles
cd ${DOTPATH}

for f in .??*
do
    # ドットから始まるディレクトリのうち、
    # .config, .zshをシンボリックリンク対象にする
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".gitignore" ]] && continue
    [[ "$f" == ".devcontainer" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".ssh" ]] && continue
    echo $f

    # すでにシンボリックリンクが存在する場合は削除
    if [ -e ${HOME}/${f} ]; then
        rm -rf ${HOME}/${f}
    fi
    ln -snfv ${DOTPATH}/${f} ${HOME}/${f}
done

# .ssh/privateのみシンボリックリンクを貼る
# ln -snfv ${DOTPATH}/.ssh/private ${HOME}/.ssh/private

echo $(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)

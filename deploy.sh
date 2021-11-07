#!/bin/bash
set -eu

DOTPATH=$HOME/.dotfiles
cd ${DOTPATH}

for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".gitignore" ]] && continue
    [[ "$f" == ".devcontainer" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue

    echo $f
    ln -snfv ${DOTPATH}/${f} ${HOME}/${f}
done
echo $(tput setaf 2)Deploy dotfiles complete!. ✔︎$(tput sgr0)

# `/opt/homebrew/opt/python3/libexec/bin`が存在する場合、PATHに追加
if [ -d /opt/homebrew/opt/python3/libexec/bin ]; then
    export PATH=/opt/homebrew/opt/python3/libexec/bin:$PATH
fi

# プロジェクトの直下に .venv を作成する
export PIPENV_VENV_IN_PROJECT=1
export PIPENV_IGNORE_VIRTUALENVS=1

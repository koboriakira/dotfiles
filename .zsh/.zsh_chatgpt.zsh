export CHATGPT_PROMPT_DIR=$HOME/git/chatgpt-prompt


function _openai-api() {
    # OpenAI APIを実行する
    # $1: プロンプト
    # $2: 【任意】YAMLファイル名(拡張子は不要)

    export-openai-api-key # APIキーを環境変数にセット


    # 引数が足りない場合はエラーを出力
    if [ $# -lt 1 ]; then
        echo "input and YAML filename are required. ex) _openai-api \"Awesome function\" \"name-branch\""
        return 1
    fi

    USER_INPUT=$1
    YAML_FILEPATH=$CHATGPT_PROMPT_DIR/$2.yaml

    if [ ! -f $YAML_FILEPATH ]; then
        echo "Not found: $YAML_FILEPATH"
        return 1
    fi

    # OpenAI APIが読み取れる形に変換したうえでcurlを実行
    sed "s/USER_INPUT/$USER_INPUT/" $YAML_FILEPATH | \
    yq eval -o json | curl --silent https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d @- | jq -r '.choices[0].message.content'

    # なおレスポンスがJSONである場合は、さらにjqコマンドで取得できる
    # ex.) _openai-api "#1 タスク削除機能を実装" name-branch | jq -r '.branch_name'
}

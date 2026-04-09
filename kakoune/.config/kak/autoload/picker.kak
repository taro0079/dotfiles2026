define-command file-picker -docstring "fzfでファイルを開く" %{
    terminal sh -c %{
        file=$(fd . --typef | fzf)
	if [ -n "$file"]; then
		echo "evaluate-commands -client $kak_client edit '$file'" | kak -p $kak_session
	fi
    }
}

map global user f :file-picker<ret> -docstring "file picker"


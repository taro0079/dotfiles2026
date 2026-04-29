#/bin/sh
# kak lsp

sudo pacman -S kakoune-lsp

# kakoune plugin
mkdir -p $HOME/.config/kak/plugins
git clone https://github.com/andreyorst/plug.kak.git $HOME/.config/kak/plugins/plug.kak

# zeno
git clone https://github.com/yuki-yano/zeno.zsh.git
echo "source /path/to/dir/zeno.zsh" >> ~/.zshrc


npm install -g @herb-tools/language-server

# Nap: terminal based snippets plugin
go install github.com/maaslalani/nap@main

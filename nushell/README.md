# Nushell

リポジトリのルートで実行します。

```sh
stow --no-folding --target="$HOME" nushell
```

既存の同名ファイルがある場合は、内容を確認してバックアップ先へ移動してから実行してください。
`--no-folding` によりファイル単位でリンクを作り、履歴やプラグインなどの実行時データがリポジトリに入るのを防ぎます。

管理対象:

- `~/.config/nushell/config.nu`
- `~/.config/nushell/env.nu`
- `~/.config/nushell/completions-jj.nu`
- `~/.config/nushell/git-completions.nu`
- `~/.zoxide.nu`

設定には npm scripts の補完も含まれます。Nushell を再起動すると変更が反映されます。

補完の更新は Nushell で以下を実行します。リンク先の管理ファイルも更新されます。

```nu
jj util completion nushell | save -f ~/.config/nushell/completions-jj.nu
http get https://raw.githubusercontent.com/nushell/nu_scripts/main/custom-completions/git/git-completions.nu | save -f ~/.config/nushell/git-completions.nu
zoxide init nushell | save -f ~/.zoxide.nu
```

Git 補完の提供元: https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu

リンクを解除する場合:

```sh
stow --delete --target="$HOME" nushell
```

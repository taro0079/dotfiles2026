# mu4e + Gmail（macOS）

mu4e で閲覧・作成し、mbsync で IMAP 同期、Emacs の smtpmail で送信する。
以下は Google のアプリパスワードが利用できるアカウント向け。
利用できない場合は OAuth2 の設定が別途必要。

## 1. ツールとアカウント

```sh
brew install mu isync
```

Google の2段階認証を有効にし、[アプリパスワード](https://myaccount.google.com/apppasswords)
を発行する。通常の Google パスワードは使わない。
発行条件は [Google の説明](https://support.google.com/accounts/answer/185833?hl=ja)を参照。

ターミナルで次を実行し、プロンプトにアプリパスワードを入力する。
アドレスを置き換える。パスワードをコマンドの引数やこのリポジトリには書かない。

```sh
security add-internet-password -a 'YOUR_ADDRESS@gmail.com' -s smtp.gmail.com -P 587 -r smtp -w
```

同じ項目がすでにある場合は、キーチェーンアクセスでその項目を更新する。
IMAP と SMTP はこの項目を共用する。アクセス許可のダイアログが出たら許可する。

## 2. ローカル設定

このディレクトリの `private-mail.el.example` を `~/.emacs.d/private-mail.el`、
`mbsyncrc.gmail.example` を `~/.mbsyncrc` にコピーする。
既存ファイルがある場合は上書きせずマージする。
両ファイルのアドレスと、private-mail.el の表示名を変更する。

```sh
chmod 600 ~/.mbsyncrc ~/.emacs.d/private-mail.el
mkdir -p ~/Maildir/gmail
mbsync -l gmail
```

`PassCmd exited with status 44` とキーチェーン項目が見つからないエラーが出る場合は、
`~/.mbsyncrc` の `User` と `PassCmd` 内の `-a` が、両方ともキーチェーンに
登録した実際のアドレスになっているか確認する。`YOUR_ADDRESS@gmail.com` のままでは接続できない。

Gmail の IMAP フォルダー名はアカウントの言語設定で異なる。
`mbsync -l gmail` は `Patterns` に一致するフォルダーだけを表示するため、
全フォルダーの実際の名前は次で確認する（isync 1.5 系）。

```sh
mbsync --list-stores gmail-remote
```

一覧に `[Gmail]/Drafts` などがなければ、`.mbsyncrc` の `Patterns` と、
`private-mail.el` 内で上書きする `mu4e-drafts-folder`、`mu4e-sent-folder`、
`mu4e-trash-folder`、`mu4e-refile-folder`、`mu4e-maildir-shortcuts` を実際の名前に合わせる。
一覧は読み取りのみで、メール本文はまだダウンロードしない。

## 3. 初回同期と索引

`All Mail` を含めるため、初回はアーカイブ済みメールもダウンロードする。
容量・所要時間はメールボックスの大きさによる。

```sh
mbsync gmail
mu init --maildir="$HOME/Maildir" --my-address='YOUR_ADDRESS@gmail.com'
mu index
```

すでに mu の索引を使っている場合は、先に `mu info` で既存の Maildir と
アドレスを確認してから統合する。上の `mu init` は新規セットアップ向け。

Emacs を再起動し、`M-x mu4e` で開く。`U` で同期、`ji` で受信箱、`C` で新規作成。
送信は作成バッファの `C-c C-c`。メール画面の `C-c c` は既存の Org capture 連携。
mu4e 起動中は5分間隔で同期する。

## 移動・削除の同期

初期値の `Expunge None` は完全削除を行わない。
既読フラグと新着は双方向に同期するが、移動元のメールがサーバーに残ることがある。
フォルダー対応と動作を確認後、完全削除も同期したい場合は `Expunge Both` に変更する。
変更すると削除マークが付いたメールが双方で完全削除されるため、Gmail の
IMAP 削除設定も確認する。[mbsync マニュアル](https://isync.sourceforge.io/mbsync.html)
の RECOMMENDATIONS を参照。

送信済みは Gmail 側の自動保存を使う。
設定の根拠は [mu4e の Gmail 設定例](https://www.djcbsoftware.nl/code/mu/mu4e/Gmail-configuration.html)。

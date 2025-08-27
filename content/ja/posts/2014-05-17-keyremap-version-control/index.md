---
title: 'KeyRemap4MacBook の設定をバージョン管理する'
description: 'KeyRemap4MacBook の設定をバージョン管理するようにしました。'
date: 2014-05-17 19:00
public: true
tags: keyremap4macbook, boxen, dotfiles, git
ogp:
  og:
    image:
      '': 2014-05-17-keyremap-version-control/icon@2x.png
      type: image/png
      width: 512
      height: 512
---

<img src="" srcset=" 2x">

今更ながら [KeyRemap4MacBook] を導入しました。キーボードのあれこれを、細かくカスタマイズできるツールです。

READMORE

Key Repeat と、その delay を、Mac の Preferences で設定できる値より短く設定しました。

<img src="" srcset=" 2x">

## Boxen

[今のところ]、[Boxen] で環境設定しているので、以下の様に個人のマニフェストを設定しました。

Puppetfile:

```rb
github "keyremap4macbook", "1.2.2"
```

modules/people/manifest/ngs.pp:

```puppet
include keyremap4macbook # インストール
include keyremap4macbook::login_item # ログイン時に開く

# 設定内容
keyremap4macbook::set{
  'repeat.initial_wait': value => '200';
  'repeat.wait': value => '10';
}
```

## CLI

[KeyRemap4MacBook] には、コマンドラインツールがあるので、どこからでも使える様に、`PATH` を通している、[~/dotfiles/bin] にシンボリックリンクを貼ってみたところ、実行ファイルがアプリケーションパッケージに無いという理由でエラーになりました。

```bash
ln -s /Applications/KeyRemap4MacBook.app/Contents/Applications/KeyRemap4MacBook_cli.app/Contents/MacOS/KeyRemap4MacBook_cli ~/dotfiles/bin/
KeyRemap4MacBook_cli
```

```
2014-05-17 18:38:00.750 KeyRemap4MacBook_cli[18013:507] No Info.plist file in application bundle or no NSPrincipalClass in the Info.plist file, exiting
```

なので、以下の様に実行ファイルを作成しました。

```bash
echo '#!/bin/sh' > ~/dotfiles/bin/KeyRemap4MacBook_cli
echo '/Applications/KeyRemap4MacBook.app/Contents/Applications/KeyRemap4MacBook_cli.app/Contents/MacOS/KeyRemap4MacBook_cli $@' >> ~/dotfiles/bin/KeyRemap4MacBook_cli
chmod +x ~/dotfiles/bin/KeyRemap4MacBook_cli
KeyRemap4MacBook_cli
```

```
Usage:
  KeyRemap4MacBook_cli list
  KeyRemap4MacBook_cli selected
  KeyRemap4MacBook_cli changed
  KeyRemap4MacBook_cli reloadxml
  KeyRemap4MacBook_cli export
  KeyRemap4MacBook_cli select INDEX
  KeyRemap4MacBook_cli set IDENTIFIER VALUE
  KeyRemap4MacBook_cli enable IDENTIFIER (alias of set IDENTIFIER 1)
  KeyRemap4MacBook_cli disable IDENTIFIER (alias of set IDENTIFIER 0)

Example:
  KeyRemap4MacBook_cli list
  KeyRemap4MacBook_cli selected
  KeyRemap4MacBook_cli changed
  KeyRemap4MacBook_cli reloadxml
  KeyRemap4MacBook_cli export
  KeyRemap4MacBook_cli select 1
  KeyRemap4MacBook_cli set repeat.wait 30
  KeyRemap4MacBook_cli enable remap.shiftL2commandL
  KeyRemap4MacBook_cli disable remap.shiftL2commandL
```

## export

上記の一覧で `export` があったので、おもむろに叩いてみると、シェルスクリプトが標準出力されました。

```
#!/bin/sh

cli=/Applications/KeyRemap4MacBook.app/Contents/Applications/KeyRemap4MacBook_cli.app/Contents/MacOS/KeyRemap4MacBook_cli

$cli set repeat.wait 10
/bin/echo -n .
$cli set repeat.initial_wait 200
/bin/echo -n .
/bin/echo
```

これを使えば、[Brewproj] へもそのまま移行できるので、`ngs.pp` に記述した、`keyremap4macbook::set` を外し、こちらを [dotfiles] リポジトリで管理することにしました。

```bash
echo '#!/bin/sh' > ~/dotfiles/env.d/keyremap4macbook.sh
KeyRemap4MacBook_cli export | grep cli >> ~/dotfiles/env.d/darwin/keyremap4macbook.sh
```

何故か`/bin/echo` でドットを出力するので、ログイン毎に見たくないため、その記述は `grep` で外しました。

Mac OS X 上で `~/dotfiles/env.d/darwin/*.sh` は自動的に `source` されます。[ngs/dotfiles env.sh]

## 追記

このスクリプトの実行に時間がかかるので、`env.d` はやめて、設定実行用のスクリプト [setup.sh] から実行する様にしました。

```bash
# time KeyRemap4MacBook_cli  set repeat.initial_wait 200
KeyRemap4MacBook_cli set repeat.initial_wait 200  0.03s user 0.02s system 55% cpu 0.090 total
```


[KeyRemap4MacBook]: https://pqrs.org/macosx/keyremap4macbook/index.html.ja
[Boxen]: http://boxen.github.com/
[今のところ]: /2014/05/08/homebrew-boxen/
[Brewproj]: /2014/05/08/homebrew-boxen/
[~/dotfiles/bin]: https://github.com/ngs/dotfiles/tree/master/bin
[dotfiles]: https://github.com/ngs/dotfiles
[ngs/dotfiles env.sh]: https://github.com/ngs/dotfiles/blob/master/env.sh#L15
[setup.sh]: https://github.com/ngs/dotfiles/blob/master/setup.sh

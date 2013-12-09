---
title: Boxen 導入でハマったことメモ
description: Boxen へ移行する際、多少ハマりがちなので、随時メモ
date: 2013-02-28 03:00
public: true
tags: boxen
---

Boxen へ移行する際、多少ハマりがちなので、随時メモ

## FileVault が必須といわれる
```bash
Please enable full disk encryption and try again
```

`--no-fde` フラグをつけて実行するか `BOXEN_NO_FDE` 環境変数を 1 にしてやる

```
$ BOXEN_NO_FDE=1 script/boxen
```

## localhost, *.dev が見れない
pow が ipfw を設定しているので、それを削除してやる

```bash
$ sudo ipfw list
00100 fwd 127.0.0.1,20559 tcp from any to me dst-port 80 in
00100 fwd 127.0.0.1,20559 tcp from any to me dst-port 80 in

$ sudo ipfw delete 00100
$ sudo vim /etc/ipfilter/ipfw.conf
```

```diff
- add 100 fwd 127.0.0.1,20559 tcp from any to me dst-port 80 in
```


## *.dev が見れない
pow と違って自分でプロセスをつくってやる必要がある
https://github.com/boxen/our-boxen/blob/master/docs/rails.md#unicorn

## 導入時にインストールされていたアプリを削除すると、boxen コマンドで再導入できない
```bash
$ sudo rm -f /var/db/.puppet_appdmg_installed_Skype
```
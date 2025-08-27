---
title: BrickPi セットアップ
description: BrickPi をサクッとセットアップした手順。
date: 2013-12-15 02:00
public: true
tags: mindstorms, raspberry pi, robot, setup, brick pi, make
---

![](brick-pi-tribot.jpg)

[BrickPi が届いて](https://ja.ngs.io/2013/12/12/brick-pi/) 年明けまで未開封で放置しておこうと思ったのですが、梱包材を捨てたくてとりあえずケースだけ組み立ててみたら、動かしたくなって、たまらず土曜の夜を使ってセットアップしました。

READMORE

作業部屋の棚に Tribot という、Mindstorms NXT の組立例の中で、一番簡単な状態で飾ってあったので、NXT Block (マイコン) 部分を取り外し、BlickPi を取り付けました。

基本的にはオフィシャルの [Getting Started](http://www.dexterindustries.com/BrickPi/getting-started/) 通りにセットアップすれば動くようになります。

MacBook Pro Retina 2012 を使いました。

## 1. Raspberry Pi を WiFi 接続できるようにする

1. Raspberry Pi に、BrickPi キット付属の SD カードを挿し、MacBook Pro の USB Ethernet に接続する。
2. Raspberry Pi の Micro USB を接続し、起動する。
3. システム環境設定 > ネットワークから USB Ethernet を選択。
4. MacBook Pro の IP アドレスが `169.254.174.219` などと表示されているので、それをコピペしておく。
5. Raspberry Pi の電源を落とし、SD カードを MacBook Pro に挿し替える。
6. マウントされた boot というボリュームの直下にある、cmdline.txt を開き、末尾に、4 の IP アドレスの最後の桁を別の値に変更したものを `ip=169.254.174.220` の様に追記する。

    ```bash
    dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait ip=169.254.174.220
    ```

7. 再度、SD カードを Raspberry Pi に差し替え、ssh でログインする。

    ```bash
    $ ssh pi@169.254.174.220 # password = raspberry
    ```
8. 次からは公開鍵認証にしたいので、cURL で公開鍵を取ってくる。

    ```bash
    $ mkdir .ssh
    $ chmod 700 .ssh
    $ curl -L http://s.liap.us/id_rsa.pub > .ssh/authorized_keys
    $ chmod 400 .ssh/authorized_keys
    ```

9. オフィシャルには、USB メモリに interfaces.dat を入れてどうのこうの、と書かれているが、直接 `/etc/network/interfaces` を編集し、`wpa-ssid`, `wpa-spk` などを適宜修正する。
10. 保存して、再起動する。
11. `/etc/network/interfaces` の `address` に設定した IP アドレスに ssh する。

    ```bash
    $ ssh pi@192.168.1.123
    ```

## 2. Python でモーターを動かす

1. 公式 Git リポジトリから clone し、ライブラリをインストール。

    ```bash
    $ git clone https://github.com/DexterInd/BrickPi_Python.git
    $ cd BrickPi_Python
    $ sudo apt-get install python-setuptools
    $ sudo python setup.py install
   ```

2. 簡単なサンプルを動かす

    ```bash
    $ cd Project_Examples/simplebot
    $ python simplebot_simple.py
    ```

    `w + enter` で前進、`a + enter` で左折、`d + enter` で右折、`s + enter` で後進、`x + enter` で停止します。

    [実装箇所: Project_Examples/simplebot/simplebot_simple.py](https://github.com/DexterInd/BrickPi_Python/blob/master/Project_Examples/simplebot/simplebot_simple.py#L58)

とても簡単に扱えたので、もっと色々試してみたいです。今度こそ、来年！

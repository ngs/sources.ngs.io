---
title: VMWare .vmdk を VirtualBox .vdi に変換する
description: VMWare で作成した仮想端末を VirtualBox に移行するのに、ハマったのでメモです。
date: 2011-02-28 10:04
public: true
tags: vmware, virtualbox, centos, macosx, vm
---

VMWare で作成した仮想端末を VirtualBox に移行するのに、ハマったのでメモです。

1.  _Virtual Machine Library_ から VM を選択、コンテキストメニューから _Settings_ を選択、もしくは `CMD+E` で設定画面を表示
2.  _HardDisks_ を選択
3.  _Split into 2 GB Files_ のチェックを外し、_Apply_ ボタンをクリック
4.  _Virtual Machine Library_ から VM を選択、コンテキストメニューから _Show In Finder_ を選択
5.  _Q.app_ をダウンロード + インストール。[Q &ndash; [kju:]](http://www.kju-app.org/)
6.  _Terminal.app_ などを使って cli で、以下のコマンドを実行

    ```bash
    $ cd ~/Documents/Virtual\ Machines
    $ /Applications/Q.app/Contents/MacOS/qemu-img convert $VMMACHINE$.vmwarevm/$VMDISK$.vmdk raw-file.bin
    $ /Applications/VirtualBox.app/Contents/MacOS/VBoxManage convertdd raw-file.bin $VMMACHINE$.vdi
    $ rm raw-file.bin
    ```

7.  _.vdi_ ファイルは、自分の管理しやすい場所に移動します。

8.  _VirtualBox.app_ を起動。
9.  ツールバーから、_New_ ボタンをクリック。ウィザードにしたがって、Name / OS / Version / Memory を然るべき値に設定
10.  _Virtual Hard Disk_ の画面まできたら _Book Hard Disk_ はチェック、_Use existing hard disk_ を選択し、プルダウン右にある、参照アイコンをクリックして、_.vdi_ ファイルを選択。ウィザードを完了させます。
11.  cli から、以下のコマンドを実行します。

    ```bash
    $ /Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvdi $VMMACHINE$.vdi compact
    ```

12.  _VirtualBox.app_ の _VirtualBox Manager_ から、VM を選択し、コンテキストメニューから、または`CMD+S` で _Settings_ を開き、_Storage_ に移動。

13.  _SATA Controller_ の下に、_.vdi_ ファイルが入っているので、選択してコンテキストメニューから _Remove Attachment_ を選択
14.  _IDE Controller_ を選択して、コンテキストメニューから _Add HardDisk_ を選択、_Choose existing disk_ を選択し、_.vdi_ ファイルを選択。_OK_ ボタンで設定完了

以上で移行が完了しました。

Mac OS X 10.6.6 / VMWare Fusion 2.0.6 / VirtualBox 4.0.4、VM は CentOS-5.5 32 bit でした。

参考にしたサイト

*   [Converting from VMware (vmdk) to VirtualBox (vdi) on Mac OS X](http://mariusvw.com/2009/08/29/converting-from-vmware-vmdk-to-virtualbox-vdi-on-mac-os-x/)
*   [Mounting/opening virtualbox disk image (vdi) on linux host](http://serverfault.com/questions/51965/mounting-opening-virtualbox-disk-image-vdi-on-linux-host)
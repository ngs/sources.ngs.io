---
title: Xcode の LLDB で Coda プラグインをデバッグする
description: Xcode の LLDB で Coda プラグインをデバッグする方法
date: 2012-05-25 20:00
public: true
tags: coda2, plug-in, xcode, lldb
---

1. **Edit Scheme** ウィンドウを開く (&#x2318;&lt;).
2. サイドバーから **Run** 項目を選択
3. **Info** タブの **Executable** プルダウンから **Coda 2.app** を選択する
4. **OK** をクリックしてウィンドウを閉じる
5. Targets から プラグインターゲットを選択する
6. **Build Settings** タブを選択し、**Add Build Setting** をクリック、**Add User-Defined Setting** を選択し、名前が `INSTALL_BUNDLE` で、Debug に対して値が `1` と設定する
5. **Build Phase** タブに切り替え **Add Build Phase** をクリックし **Add Run Script** を選択する
7. 以下のスクリプトをコピペする

```bash
if [ $INSTALL_BUNDLE == 1 ]; then
  DEST="$USER_LIBRARY_DIR/Application Support/Coda 2/Plug-ins/$FULL_PRODUCT_NAME"
  ORG="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"
  rm -rf "$DEST"
  mv "$ORG" "$DEST"
fi
```

これで Run からデバッグできます
---
title: "Debugging Coda Plug-In with LLDB"
date: 2012-05-25 12:00
public: true
tags: coda 2, xcode, lldb
alternate: true
---

1. Open **Edit Scheme** window (&#x2318;&lt;).
2. Select **Run** pane from side bar.
3. In **Info** tab, select **Coda 2.app** from **Executable** dropdown.
4. Click the **OK** button to close the window.
5. Select your your plug-in target.
6. Select **Build Settings** tab, click **Add Build Setting**, select **Add User-Defined Setting** and set name as `INSTALL_BUNDLE`, value as `1` for Debug configuration.
5. Switch to **Build Phase** tab, click **Add Build Phase** button and select **Add Run Script**
7. Copy and paste the script bellow.

```bash
if [ $INSTALL_BUNDLE == 1 ]; then
  DEST="$USER_LIBRARY_DIR/Application Support/Coda 2/Plug-ins/$FULL_PRODUCT_NAME"
  ORG="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"
  rm -rf "$DEST"
  mv "$ORG" "$DEST"
fi
```


Now you can debug with your LLDB console, enjoy!

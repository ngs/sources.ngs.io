if [ $INSTALL_BUNDLE == 1 ]; then
  DEST="$USER_LIBRARY_DIR/Application Support/Coda 2/Plug-ins/$FULL_PRODUCT_NAME"
  ORG="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"
  rm -rf "$DEST"
  mv "$ORG" "$DEST"
fi

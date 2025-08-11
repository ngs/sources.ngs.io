---
title: iTerm 2 のカラースキームをファイル書出し/読込みをする
description: iTerm 2 のカラースキームをファイル書出し/読込みをする
date: 2014-05-05 14:00
public: true
tags: iterm2, shell
alternate: true
---

連休で暇なので、[Boxen] の代わりに [dotfiles] を使って Git リポジトリで諸々環境設定を管理する方法を検証しています。

iTerm 2 のカラースキームも [puppet-iterm2] というモジュールを使って管理していて、とても便利でした。

READMORE

[dotfiles] に以降するために、iTerm 2 のカラースキームをファイル書出し/読込みをする、以下のスクリプトを作りました。

### 書出し:

iTerm 2 に設定されているカラースキームを書出します。

```sh
mkdir -p ~/Desktop/iterm2-color-schemes
cd ~/Desktop/iterm2-color-schemes
rm -f *

/usr/libexec/PlistBuddy -c "print :'Custom Color Presets'" \
  ~/Library/Preferences/com.googlecode.iterm2.plist | grep '^    \w' | \
  ruby -e 'puts STDIN.read.gsub(/\s=\sDict\s{/,"").gsub(/^\s+/,"")' > list.txt

while read THEME; do
  echo "exporting ${THEME}"
  /usr/libexec/PlistBuddy -c "print :'Custom Color Presets':'$THEME'" \
    ~/Library/Preferences/com.googlecode.iterm2.plist | \
    ruby -e "puts STDIN.read.strip.gsub(/Dict {/, '{')
      .gsub(/([A-Z][a-z0-9\s]+)\s=\s/i, %Q{'\\1' = })
      .gsub(/(\d(?:\.\d+)?)$/, %Q{'\\1';})
      .gsub(/}\n/, %Q(};\n))" > "$THEME"
done < list.txt

rm list.txt
cd -
```


### 読込み:

```sh
cd ~/Desktop/iterm2-color-schemes
for f in *; do
  THEME=$(basename "$f")
  defaults write -app iTerm 'Custom Color Presets' -dict-add "$THEME" "$(cat "$f")"
done
cd -
```


[Boxen]: http://boxen.github.com/
[dotfiles]: https://github.com/ngs/dotfiles/
[puppet-iterm2]: https://github.com/ngs/puppet-iterm2

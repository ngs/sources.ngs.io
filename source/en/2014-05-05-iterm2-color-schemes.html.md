---
title: Exporting and importing iTerm 2 Color Schemes
description: Exporting and importing iTerm 2 Color Schemes
date: 2014-05-05 14:00
public: true
tags: iterm2, shell
alternate: true
---

I started to manage stuffs with [dotfiles] git repository instead of [Boxen].

I managed iTerm 2 color schemes with [puppet-iterm2] modules, that was very useful.

READMORE

To migrate to [dotfiles], I wrote the following scripts to export/import iTerm 2 color schemes.

### Exporting:

This exports color schemes configured in your iTerm 2.

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


### Importing:

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

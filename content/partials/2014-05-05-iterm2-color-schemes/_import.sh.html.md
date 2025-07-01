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
      .gsub(/([A-Z][a-z0-9\\s]+)\\s=\\s/i, %Q{'\\\\1' = })
      .gsub(/(\\d(?:\.\\d+)?)$/, %Q{'\\\\1';})
      .gsub(/}\\n/, %Q(};\n))" > "$THEME"
done < list.txt
rm list.txt
cd -

module EmojiHelper
  def emojify(content, mode = nil)
    content.to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        if mode == :raw
          emoji.raw
        else
          %(<img alt="#$1" src="https://assets-cdn.github.com/images/icons/emoji/#{emoji.image_filename}?v5" style="width: 1em; vertical-align:middle" class="gemoji">)
        end
      else
        match
      end
    end if content.present?
  end
end

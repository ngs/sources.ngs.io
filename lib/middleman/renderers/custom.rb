require 'middleman-core/renderers/redcarpet'
require 'middleman-syntax/extension'
require 'slim'

class String
  def identify
    self.downcase.gsub(/[^\w]/, '-')
  end
end

module Middleman
  module Renderers
    class CustomTemplate < RedcarpetTemplate
      def allows_script
        true
      end
    end
    module CustomRenderer
      def table(header, body)
        res = '<table class="table table-bordered">'
        res += "<thead>#{header}</thead>" if header.present?
        res += "<tbody>#{body}</body>"
        res + '</table>'
      end
      def block_code(code, language)
        code.gsub!(%r{[\n\r\s]*$}, '')
        Middleman::Syntax::Highlighter.highlight(code, language)
      end
    end
  end
end

Middleman::Renderers::MiddlemanRedcarpetHTML.send :include, ::Middleman::Renderers::CustomRenderer

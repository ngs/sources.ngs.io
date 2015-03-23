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
      def list_item(content, list_type)
        node_name = { ordered: 'ol', unordered: 'li' }[list_type]
        content.sub!(/^\s*\[\s+\]/, '<input type="checkbox" disabled>')
        content.sub!(/^\s*\[\s*x\s*\]/, '<input type="checkbox" checked disabled>')
        "<#{node_name}>#{content}</#{node_name}>"
      end
    end
  end
end

Middleman::Renderers::MiddlemanRedcarpetHTML.send :include, ::Middleman::Renderers::CustomRenderer

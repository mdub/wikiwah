require 'wikiwah/flow'
require 'wikiwah/subst'

module WikiWah

  class Converter

    attr_writer :link_translator

    def initialize
      @link_translator = proc do |link| link end
        init_transformer
      end

      # Convert WikiWah text to HTML.
      def convert(text)
        Flow.convert(text) do |paragraph|
          @transformer.transform(paragraph)
        end
      end

      private

      def translate_link(link)
        @link_translator.call(link)
      end

      def init_transformer
        @transformer = WikiWah::Subst.new 
        @transformer.add_transformation(/""(.+)""/) do |match|
          # Double-double-quoted
          CGI.escapeHTML(match[1])
        end
        @transformer.add_transformation(/\\(.)/) do |match|
          # Backslash-quoted
          match[1]
        end
        @transformer.add_transformation(/\<(.+?)\>/m) do |match| 
          # In-line HTML
          match[0] 
        end
        @transformer.add_transformation(/\{(.+?)\}(@(\S*[\w\/]))?/m) do |match|
          # Distinuished link
          label = @transformer.transform(match[1])
          location = translate_link(match[3] || match[1])
          if location
            "<a href='#{location}'>#{label}</a>"
          else
            "{#{label}}"
          end
        end
        @transformer.add_transformation(/\b[a-z]+:[\w\/]\S*[\w\/]/) do |match|
          # URL
          "<a href='#{match[0]}'>#{match[0]}</a>"
        end
        @transformer.add_transformation(%r[(^|\W)([*+_/])([*+_/]*\w.*?\w[*+_/]*)\2(?!\w)]) do |match|
          # Bold/italic/etc.
          tag = case match[2]
          when '*'; 'strong'
          when '+'; 'tt'
          when '/'; 'em'
          when '_'; 'u'
          end
          content = @transformer.transform(match[3])
          (match[1] + '<' + tag + '>' + content + '</' + tag + '>')
        end
      end

    end

end

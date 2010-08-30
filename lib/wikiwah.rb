require 'wikiwah/flow'
require 'wikiwah/subst'
require 'wikiwah/version'

# A formatter for turning Wiki-esque text into HTML.
#
# = Block-level markup
#
# - A line prefixed by "=" is a heading.  The heading-level is implied by
#   the number of "=" characters.
#
# - A line beginning with "*" or "-" is an unordered list item.
#
# - A line beginning with "1.", "(1)" or "#" is an ordered list item.
#
# - A paragraph prefixed by "|" is preformatted text (e.g. code)
#
# - A paragraph prefixed by ">" is a blockquote (ie. a citation)
#
# = Text markup
#
# - HTML tags are rendered verbatim.
#
# - Text may by marked *bold*, /italic/, _underlined_, +monospace+
#
# - Text may be quoted with '{{{' and '}}}'
#
# - URLs turn into links.
#
# - "{LOCATION}" creates a link to LOCATION.
#
# - "{LABEL}@LOCATION" creates a link to LOCATION, with the specified
#   LABEL.
#
class WikiWah

  attr_writer :link_translator

  def initialize
    @link_translator = proc do |link| link end
    init_transformer
  end

  # Convert WikiWah text to HTML.
  def to_html(text)
    Flow.convert(text) do |paragraph|
      @transformer.transform(paragraph)
    end
  end
  
  def self.to_html(text)
    self.new.to_html(text)
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


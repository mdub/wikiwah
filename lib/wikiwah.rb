require 'wikiwah/converter'
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
module WikiWah

  def self.convert(text)
    Converter.new.convert(text)
  end

end

Wikiwah = WikiWah

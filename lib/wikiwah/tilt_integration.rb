require "tilt"
require "wikiwah"

module WikiWah
  
  class Template < Tilt::Template

    def prepare
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= WikiWah.convert(data)
    end

  end

end

Tilt.register 'wah', WikiWah::Template

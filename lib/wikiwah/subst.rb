#!/usr/bin/env ruby

class WikiWah

  # Subst handles text-transformation using a series of regular-expression
  # substitutions.  It encapsulates a number of "patterns", and associated
  # blocks.  Each block is invoked with a MatchData object when it's
  # associated pattern matches, and is expected to return a replacement
  # string.
  #
  # The difference between using Subst and applying a series of gsub's is
  # that replacement values are protected from subsequent transformations.
  class Subst
    
    def initialize
      @transforms = []
    end
    
    def add_transformation(regexp, &proc)
      @transforms << [regexp, proc]
    end

    def transform(s)
      s = s.dup
      store = []
      @transforms.each do |transform|
        (regexp, proc) = *transform
        s.gsub!(regexp) {
          store << proc.call($~)
          "\001#{store.size - 1}\002"
        }
      end
      s.gsub!(/\001(\d+)\002/) {
        store[$1.to_i]
      }
      s
    end
    
  end

end

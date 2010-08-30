#!/usr/bin/env ruby

require 'cgi'                   # for escapeHTML

class WikiWah

  # Flow deals with block-level formatting in WikiWah.  Input text is split
  # into paragraphs, separated by blank lines.  A list-item bullet also
  # implies a new paragraph.
  #
  # Flow keeps track of the current level of indentation, and emits
  # block-start and block-end tags (e.g. "<li>", "</li>") as required.
  #
  # Flow recognises the following types of blocks:
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
  # - Anything else is plain old body text.
  #
  class Flow

    # Convert +input+ text to HTML. 
    #
    # An optional +filter+ block may be provided, in which case it's
    # applied to the body of each block.
    def Flow.convert(input, &filter)
      buff = ''
      parser = Flow.new(buff,filter)
      parser.process(input)
      buff
    end
    
    # Patterns that start a new block
    BlankRegexp = /\A *$/
    BulletRegexp = Regexp.new('\A *([\*\-\#]|\d+\.|\(\d+\)) ')
    
    def initialize(out, text_filter=null)
      @out = out
      @text_filter = text_filter
      @context_stack = [TopContext]
      @block_buffer = nil
    end
    
    # Process a multi-line input string
    def process(input)
      add_input(input)
      flush_context_stack
    end

    private
    
    # Process multi-line input
    def add_input(input) 
      input.each do |line|
        if (line =~ BlankRegexp)
          start_new_block
        else
          if (line =~ BulletRegexp)
            start_new_block 
          end
          append_to_block(line)
        end
      end
      start_new_block
    end
    
    # Append a line to the block
    def append_to_block(line)
      @block_buffer = (@block_buffer || '') + line
    end

    # Flush the buffered block
    def start_new_block
      if (@block_buffer) 
        add_block(@block_buffer)
        @block_buffer = nil
      end
    end

    # Add a block
    def add_block(block)
      case block
      when /\A( *)- /       # unordered list item
        push_context('ul',$1.size)
        write_tag($', 'li')
      when /\A( *)\* /       # unordered list item
        push_context('ul class="sparse"',$1.size)
        write_tag($', 'li')
      when /\A( *)(\#|\d+\.|\(\d+\)) / # ordered list item
        push_context('ol',$1.size)
        write_tag($', 'li')
      when /\A( *)% /       # unordered list item
        push_context('dl',$1.size)
        write_tag($', 'dt')
      when /\A(( *)> )/           # citation
        push_context('blockquote',$2.size)
        block = strip_prefix($1, block)
        write_text(block)
      when /\A(( *)\| )/          # preformatted (explicit)
        push_context('pre',$2.size)
        block = strip_prefix($1, block)
        write_html(CGI.escapeHTML(block))
      when /\A( *)(=+) /        # heading
        flush_context_stack
        write_tag($', "h#{$2.size}")
      when /\A( *)/        	# body text
        tag = \
        if $1 == ""
          'p'
        elsif context.tag == 'dl'
          'dd'
        else
          'blockquote'
        end
        push_context(tag,$1.size,true)
        block = strip_prefix($1, block)
        write_text(block)
      end
    end
    
    def strip_prefix(prefix, text)
      pattern = '^' + Regexp.quote(prefix)
      pattern.sub!(/\\ $/, '( |$)')
      regexp = Regexp.new(pattern)
      text.gsub(regexp, '')
    end

    # Write a balanced tag
    def write_tag(content, tag)
      write_html("<#{tag}>\n")
      write_text(content)
      write_html("</#{tag}>\n")
    end
    
    # Write HTML markup
    def write_html(html)
      @out << html
    end
    
    # Write text content, performing any necessary substitutions
    def write_text(text)
      if (@text_filter)
        text = @text_filter.call(text)
      end
      @out << text
    end
    
    Context = Struct.new('Context', :tag, :level)
    TopContext = Context.new(:top, -1)
    
    # Get the current Context
    def context
      @context_stack.last
    end

    # Push a new Context on the stack
    def push_context(tag_with_arguments, level, separate_same=false)
      match = %r{^(\w+)(.*)$}.match(tag_with_arguments)
      tag = match[1]
      arguments = match[2]
      original_level = context.level
      pop_context_to_level(level)
      if (context.level == level)
        if (context.tag != tag)
          pop_context
        elsif (separate_same)
          write_html("</#{tag}>\n")
          write_html("<#{tag}#{arguments}>\n")
        end
      end
      if (context.level < level)
        write_html("<#{tag}#{arguments}>\n")
        @context_stack << Context.new(tag,level)
      end
    end

    # Pop topmost Context from the stack
    def pop_context
      if (context == TopContext)
        raise "can't pop at top"
      end
      cxt = @context_stack.pop
      write_html("</#{cxt.tag}>\n")
    end
    
    def pop_context_to_level(level)
      while (context.level > level)
        pop_context
      end
    end

    # Pop all Contexts from the stack
    def flush_context_stack
      while (context != TopContext)
        pop_context
      end
    end
    
  end

end

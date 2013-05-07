#!/usr/bin/env ruby

require 'wikiwah/flow'
require 'test/unit'

# Tests follow.  The structure is
#
#   ====
#   #{input}
#   ----
#   #{expected_output}
#
# This script will complain if the actual output doesn't match.

TESTS = <<END_OF_TESTS

==== # Paragraph
Simple paragraph
----
<p>
Simple paragraph
</p>

==== # Two paragraphs
P1

P2
----
<p>
P1
</p>
<p>
P2
</p>

==== # List: one item
* List
----
<ul class="sparse">
<li>
List
</li>
</ul>

==== # List: two items
* item 1
* item 2
----
<ul class="sparse">
<li>
item 1
</li>
<li>
item 2
</li>
</ul>

==== # Nested lists
* item 1
  - item 1.1
* item 2
----
<ul class="sparse">
<li>
item 1
</li>
<ul>
<li>
item 1.1
</li>
</ul>
<li>
item 2
</li>
</ul>

==== # Numbered list
# item 1
# item 2
----
<ol>
<li>
item 1
</li>
<li>
item 2
</li>
</ol>

==== # Numbered list followed by un-numbered list
# item 1
* item 2
----
<ol>
<li>
item 1
</li>
</ol>
<ul class="sparse">
<li>
item 2
</li>
</ul>

==== # Paragraph/list
P1

- item 1
----
<p>
P1
</p>
<ul>
<li>
item 1
</li>
</ul>

==== # Paragraph/nested-list
P1

  - item 1
----
<p>
P1
<ul>
<li>
item 1
</li>
</ul>
</p>

==== # List/paragraph
- item 1

P1
----
<ul>
<li>
item 1
</li>
</ul>
<p>
P1
</p>

==== # Paragraph/list/paragraph
P1

- item 1

P2
----
<p>
P1
</p>
<ul>
<li>
item 1
</li>
</ul>
<p>
P2
</p>

==== # Code
| code
|
| more code
----
<pre>
<code>code

more code
</code></pre>

==== # Blockquote
> block
> quote
----
<blockquote>
block
quote
</blockquote>

==== # Blockquote with space
> block
>
> quote
----
<blockquote>
block

quote
</blockquote>

====
> q1

  - item

> q2
----
<blockquote>
q1
<ul>
<li>
item
</li>
</ul>
q2
</blockquote>

====
  - item

  | code
----
<ul>
<li>
item
</li>
</ul>
<pre>
<code>code
</code></pre>

====
* item

  | code
----
<ul class="sparse">
<li>
item
</li>
<pre>
<code>code
</code></pre>
</ul>

====
Text with <tags> in
----
<p>
Text with <tags> in
</p>

====
drink XXXX
----
<p>
drink BEER
</p>

====
= HEAD
  - blah
----
<h1>
HEAD
</h1>
<ul>
<li>
blah
</li>
</ul>

====
P1

  quote

P2
----
<p>
P1
<blockquote>
quote
</blockquote>
</p>
<p>
P2
</p>

====
P1

  quote
    - xxx
----
<p>
P1
<blockquote>
quote
<ul>
<li>
xxx
</li>
</ul>
</blockquote>
</p>

====
1. juan
2. two
----
<ol>
<li>
juan
</li>
<li>
two
</li>
</ol>

====
(1) juan
(2) two
----
<ol>
<li>
juan
</li>
<li>
two
</li>
</ol>

====
| x
| |y|
| z
----
<pre>
<code>x
|y|
z
</code></pre>

====
- list item

== header
----
<ul>
<li>
list item
</li>
</ul>
<h2>
header
</h2>

====
% term1

    definition1

% term2

    definition2
----
<dl>
<dt>
term1
</dt>
<dd>
definition1
</dd>
<dt>
term2
</dt>
<dd>
definition2
</dd>
</dl>

====
b4

% term1

  def1

after
----
<p>
b4
</p>
<dl>
<dt>
term1
</dt>
<dd>
def1
</dd>
</dl>
<p>
after
</p>
END_OF_TESTS

module WikiWah
  class FlowTests < Test::Unit::TestCase

    TESTS.split(/\n====.*\n/).each_with_index do |test, i|
      (input, expected) = test.split(/----\n/)
      next unless expected
      define_method("test_#{i}") do
        actual = WikiWah::Flow.convert(input) do |s|
          s.gsub(/XXXX/, "BEER")
        end
        expected[/\s*\z/] = ''
        actual[/\s*\z/] = ''
        assert_equal(expected, actual)
      end
    end

  end
end


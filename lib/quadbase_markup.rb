# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
#require 'parslet/convenience'

class QuadbaseParser < Parslet::Parser
  
  def parse(str)
    # Always make sure we have one 'paragraph'
    super(str.strip + "\n\n")
  end

  # TODO add \# and \* as allowed in text

  root(:paragraphs)

  rule(:paragraphs) { paragraph.repeat.as(:paragraphs) }
  rule(:paragraph) { (( line | bulleted_list | numbered_list ).repeat(1) >> spaces >> eol).as(:paragraph) }
  
  rule(:line) { (content >> eol).as(:line) }
  rule(:content) { (math | image | bold | italic | underline | text).repeat(1) }

  rule(:text) { (
                  ( # Escape characters
                    str("\\$") | str("\\*") | str("\\#")
                  ) | (
                    math_inline_tag.absent? >>
                    math_display_tag.absent? >>
                    numbered_item_tag.absent? >> 
                    bullet_tag.absent? >> 
                    image_start_tag.absent? >> 
                    bold_tag.absent? >> 
                    italic_tag.absent? >> 
                    underline_tag.absent? >>
                    eol.absent? >> 
                    any
                  )
                ).repeat(1).as(:text) }
  
  rule(:bold_tag) { str("!!") }
  rule(:bold) { bold_tag >> content.as(:bold) >> bold_tag }
    
  rule(:italic_tag) { str("''") }
  rule(:italic) { italic_tag >> content.as(:italic) >> italic_tag }
  
  rule(:underline_tag) {str("__") }
  rule(:underline) {underline_tag >> content.as(:underline) >> underline_tag }
  
  rule(:bullet_tag) { str("*") }
  rule(:bullet) { bullet_tag >> spaces >> content.as(:bullet) }
  rule(:bulleted_list) { (bullet >> eol).repeat(1).as(:bulleted_list) }

  rule(:numbered_item_tag) { str("#") }
  rule(:numbered_item) { numbered_item_tag >> spaces >> content.as(:numbered_item) }
  rule(:numbered_list) { (numbered_item >> eol).repeat(1).as(:numbered_list) }

  rule(:filename) { match['a-zA-Z0-9_\.\-\(\) '].repeat(1) }
  rule(:image_start_tag) { str("{img:") }
  rule(:image) {  (image_start_tag >> filename.as(:filename) >> str("}")).as(:image) }
  
  rule(:math_inline_tag) { str("$") }
  rule(:math_display_tag) { str("$$") }
  rule(:math) {
    (math_inline_tag >> (math_inline_tag.absent? >> any).repeat(1) >> math_inline_tag |
    math_display_tag >> (math_display_tag.absent? >> any).repeat(1) >> math_display_tag).as(:math)
  }
  
  rule(:end_of_paragraph) { eol >> spaces >> eol }
  rule(:eol) { crlf | lf }
  rule(:crlf) { str("\r\n") }
  rule(:lf) { str("\n") }
  
  rule(:spaces) { space.repeat }
  rule(:space) { str(' ') }
  rule(:space?) { space.maybe }

  # We used to allow bold and italicized content to break over multiple lines, using the 
  # following rules.  Now we don't allow that.
  #
  # rule(:lines_of_text) { (image.as(:image) | bold | italic | text.as(:text) | eol).repeat(1) }
  # rule(:bold) { bold_tag >> lines_of_text.as(:bold) >> bold_tag }
  # rule(:italic) { italic_tag >> lines_of_text.as(:italic) >> italic_tag }

  # The parslet tricks page talks about eof, but don't think it is useful to us
  # rule(:eof) { any.absent? }  
  
  # Old paragraph rule
  # rule(:paragraph) { ( ((content | bullet | numbered_item) >> eol ).repeat(1) >> 
  #                    spaces >> 
  #                    eol).as(:paragraph) }
  
end

# Until Parslet 1.3, you can't pass any local variables into the transformer.  So,
# regrettably, we use this semi-global-like TagHelper class to do the transforming
# work that requires some outside knowledge.  
class TagHelper
  
  @@image_tag_maker = nil
  
  def self.image_tag_maker=(image_tag_maker)
    @@image_tag_maker = image_tag_maker
  end
  
  def self.make_image_tag(filename)
    @@image_tag_maker.make_tag(filename)
  end
  
end

class QuadbaseHtmlTransformer < Parslet::Transform
  rule(:italic => sequence(:entries)) { "<i>#{entries.join(' ')}</i>"}
  rule(:bold => sequence(:entries)) { "<b>#{entries.join(' ')}</b>"}
  rule(:underline => sequence(:entries)) { "<u>#{entries.join(' ')}</u>"}
  rule(:text => simple(:text)) { "#{text}" }
  rule(:line => sequence(:entries)) { entries.join }
  rule(:paragraph => sequence(:entries)) { "<p>#{entries.join}</p>" }
  rule(:paragraphs => sequence(:entries)) { entries.join("\n") }
  rule(:filename => simple(:filename)) { "#{filename}" }
  rule(:image => simple(:filename)) { "<center>" + TagHelper.make_image_tag(filename) + "</center>" }
  rule(:bullet => sequence(:text)) { "<li>#{text.join}</li>" }
  rule(:bulleted_list => sequence(:bullets)) { "<ul>#{bullets.join("\n")}</ul>" }
  rule(:numbered_item => sequence(:text)) { "<li>#{text.join}</li>" }
  rule(:numbered_list => sequence(:entries)) { "<ol>#{entries.join("\n")}</ol>" }
  rule(:math => simple(:text)) { "#{text}"}
end

# class QuadbaseTextOnlyTransformer < Parslet::Transform
#   rule(:italic => sequence(:entries)) { "#{entries.join(' ')}"}
#   rule(:bold => sequence(:entries)) { "#{entries.join(' ')}"}
#   rule(:underline => sequence(:entries)) { "#{entries.join(' ')}"}
#   rule(:text => simple(:text)) { "#{text}" }
#   rule(:line => sequence(:entries)) { entries.join }
#   rule(:paragraph => sequence(:entries)) { "#{entries.join}\n\n" }
#   rule(:paragraphs => sequence(:entries)) { entries.join("\n") }
#   rule(:filename => simple(:filename)) { "" }
#   rule(:image => simple(:filename)) { "!IMAGE!" }
#   rule(:bullet => sequence(:text)) { "* #{text.join}" }
#   rule(:bulleted_list => sequence(:bullets)) { "#{bullets.join("\n")}\n" }
#   rule(:numbered_item => sequence(:text)) { "# #{text.join}" }
#   rule(:numbered_list => sequence(:entries)) { "#{entries.join("\n")}\n" }
#   rule(:math => simple(:text)) { "!MATH!"}
# end

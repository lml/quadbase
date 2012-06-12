# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

class QuadbaseParserTest < ActiveSupport::TestCase
  
  def setup
    @parser = QuadbaseParser.new
  end
  
  test "space" do
    parser = QuadbaseParser.new
    assert_equal parser.space.parse(" ").to_s, " "
  end
  
  test "space?" do
    parser = QuadbaseParser.new
    assert_equal parser.space?.parse(" ").to_s, " "
    assert_equal parser.space?.parse("").to_s, ""
  end
  
  test "spaces" do
    parser = QuadbaseParser.new
    assert_equal parser.spaces.parse("     ").to_s, "     "
    assert_equal parser.spaces.parse("").to_s, ""
  end
  
  test "lf" do
    parser = QuadbaseParser.new
    assert_equal parser.lf.parse("\n").to_s, "\n"
    assert_raise(Parslet::UnconsumedInput) {parser.lf.parse("\n\n")}
  end
  
  test "crlf" do
    parser = QuadbaseParser.new
    assert_equal parser.crlf.parse("\r\n").to_s, "\r\n"
    assert_raise(Parslet::UnconsumedInput) {parser.crlf.parse("\r\n\r\n")}
  end
  
  test "eol" do
    parser = QuadbaseParser.new
    assert_equal parser.eol.parse("\r\n").to_s, "\r\n"
    assert_equal parser.eol.parse("\n").to_s, "\n"
    assert_raise(Parslet::UnconsumedInput) {parser.eol.parse("\r\n\r\n")}
    assert_raise(Parslet::UnconsumedInput) {parser.eol.parse("\n\n")}
  end
  
  test "end_of_paragraph" do
    parser = QuadbaseParser.new
    
    assert_nothing_raised { parser.end_of_paragraph.parse("\r\n\r\n") }
    assert_nothing_raised { parser.end_of_paragraph.parse("\r\n  \n") }
  end
  
  test "italic_tag" do
    parser = QuadbaseParser.new
    assert_equal parser.italic_tag.parse("''").to_s, "''"
  end
  
  test "italic" do
    parser = QuadbaseParser.new

    output = parser.italic.parse("''howdy''")
    assert_equal output[:italic][0][:text], "howdy"
    
    # output = parser.italic.parse("''multiline\ntest''")
    # assert_equal output[:italic][0][:text], "multiline"
    # assert_equal output[:italic][1][:text], "test"
  end
  
  test "text" do
    parser = QuadbaseParser.new

    assert_nothing_raised {parser.text.parse("This is some simple text.")}
    assert_nothing_raised {
      parser.text.parse("This is some complex text \\$  \\#  \\* ; - % ^ ! ~ ( ) [ ] + `.")
    } 
    assert_raise(Parslet::ParseFailed) {parser.text.parse("\n")}
    assert_raise(Parslet::UnconsumedInput) {parser.text.parse("Howdy $ $ \r\n buddy")}
    assert_raise(Parslet::ParseFailed) {parser.text.parse("''Howdy $ $ buddy")}
  end
  
  # test "lines_of_text" do
  #   parser = QuadbaseParser.new
  # 
  #   assert_nothing_raised {parser.lines_of_text.parse("Multiline\ntest")}
  # end
  
  test "bold" do
    parser = QuadbaseParser.new

    assert_nothing_raised {parser.bold.parse("!!this is bolded!!")}
  end

  test "content" do
    parser = QuadbaseParser.new
    output = parser.content.parse("I'd really ''like'' to know your ''name''.")
    
    assert_equal output[0][:text], "I'd really "
    assert_equal output[1][:italic][0][:text], "like"
    assert_equal output[2][:text], " to know your "
    assert_equal output[3][:italic][0][:text], "name"
    assert_equal output[4][:text], "."
  end
  
  test "content_2" do
    parser = QuadbaseParser.new
    output = parser.content.parse("I'd really !!like!! to know your ''name''.")
    
    assert_equal output[0][:text], "I'd really "
    assert_equal output[1][:bold][0][:text], "like"
    assert_equal output[2][:text], " to know your "
    assert_equal output[3][:italic][0][:text], "name"
    assert_equal output[4][:text], "."
  end
  
  test "bold_in_italic" do
    parser = QuadbaseParser.new
    output = parser.content.parse_with_debug("I'd really !!like to know your ''name''!!.")
    
    assert_equal output[0][:text], "I'd really "
    assert_equal output[1][:bold][0][:text], "like to know your "
    assert_equal output[1][:bold][1][:italic][0][:text], "name"
    assert_equal output[2][:text], "."
  end
  
  test "italic_in_bold" do
    parser = QuadbaseParser.new
    output = parser.content.parse_with_debug("I'd really ''like to know your !!name!!''.")
    
    assert_equal output[0][:text], "I'd really "
    assert_equal output[1][:italic][0][:text], "like to know your "
    assert_equal output[1][:italic][1][:bold][0][:text], "name"
    assert_equal output[2][:text], "."
  end
  
  test "paragraph" do
    parser = QuadbaseParser.new
    
    assert_nothing_raised {
      parser.paragraph.parse("This is a simple paragraph.\r\n\r\n")
    }

    assert_nothing_raised {
      parser.paragraph.parse("This is a paragraph\n that contains ''italicized'' text\n over 3 lines\n\n")
    }
  end
  
  test "paragraphs" do
    parser = QuadbaseParser.new

    assert_nothing_raised {    
      parser.paragraphs.parse("This is a short paragraph $x^2$.\n\nFollowed by a ''multi-line''\nparagraph\n\n")
    }
  end
  
  test "filename" do
    parser = QuadbaseParser.new
    assert_nothing_raised {
      parser.filename.parse("my_test_file.png")
      parser.filename.parse("hi there")
      parser.filename.parse("hithere-01")
      parser.filename.parse("hi (1).png")
    }

    assert_raise(Parslet::UnconsumedInput) {parser.filename.parse("hi\nthere")}
    assert_raise(Parslet::UnconsumedInput) {parser.filename.parse("hi$here")}
    assert_raise(Parslet::UnconsumedInput) {parser.filename.parse("hi}")}
  end
  
  test "image" do
    parser = QuadbaseParser.new
    assert_nothing_raised {
      parser.image.parse("{img:my_test_file.png}")
    }
    assert_raise(Parslet::ParseFailed) {parser.image.parse("{img file.png}")}
    assert_raise(Parslet::ParseFailed) {parser.image.parse("{img:file$}")}
  end
  
  test "image_in_paragraph" do
    assert_nothing_raised {
      @parser.paragraph.parse("hi {img:file}\n\n")
      @parser.paragraph.parse("Here's some {img:file} text with an image in it.\n\n")
    }
  end
  
  test "bullet" do
    assert_nothing_raised {
      @parser.bullet.parse("* a bullet point")
      @parser.bullet.parse("* a bullet point $x^2$ !!bold!!")
    }
    assert_raise(Parslet::UnconsumedInput) {@parser.bullet.parse("* a bad \n bullet point")}    
  end
  
  test "bulleted_list" do
    assert_nothing_raised {
      @parser.bulleted_list.parse("* a bullet point\n*another point\n")
    }
    assert_raise(Parslet::ParseFailed) {@parser.bulleted_list.parse("* a bad *bullet point")}
    assert_raise(Parslet::UnconsumedInput) {@parser.bulleted_list.parse("* a bad \n\n*bullet point")}
  end
  
  test "bullet_with_paragraph" do
    assert_nothing_raised {
      @parser.paragraphs.parse("some text\n* a bullet point\n\n")
      @parser.paragraphs.parse("a paragraph\n\n* a bullet point\n\n")
    }    
  end
  
  test "multiple bullets" do
    assert_nothing_raised {
      @parser.paragraphs.parse("some text\n* a bullet point\n* bullet point 2\n* point 3\n\n")
    }        
    assert_raise(Parslet::UnconsumedInput) {
      # Can't have a space before the bullet tag
      @parser.paragraphs.parse("some text\n* a bullet point\n* bullet point 2\n * point 3\n\n")
    }
  end
  
  test "numbered_item" do
    assert_nothing_raised {
      @parser.numbered_item.parse("# a numbered_item")
      @parser.numbered_item.parse("# a numbered item $x^2$ !!bold!!")
    }
    assert_raise(Parslet::ParseFailed) {@parser.numbered_item.parse("* a bad \n numbered_item")}    
  end
  
  test "numbered_list" do
    assert_nothing_raised {
      @parser.numbered_list.parse("# a bullet point\n#another point\n")
    }
    assert_raise(Parslet::ParseFailed) {@parser.numbered_list.parse("# a bad #bullet point")}
    assert_raise(Parslet::UnconsumedInput) {@parser.numbered_list.parse("# a bad \n\n#bullet point")}
  end
  
  test "numbered_item with paragraph" do
    assert_nothing_raised {
      @parser.paragraphs.parse("some text\n# a numbered_item point\n\n")
      @parser.paragraphs.parse("a paragraph\n\n# a numbered_item point\n\n")
    }    
  end
  
  test "math" do
    assert_nothing_raised {
      @parser.math.parse("$x^2 # {} & !! !! * $")
      @parser.math.parse("$$ \n \\int_i^2 $$")
    }        
  end
  
  test "math_in_paragraph" do
    @parser.paragraphs.parse("some text $x^2 # {} & !! !! * $\n\n")
    @parser.paragraphs.parse("some text ''italics!''\n\nanother paragraph $x^2 # {} & !! !! * $\n\n")
  end

  test "text_then_bullets_then_list" do
    @parser.paragraphs.parse("Some text\n* This is !!math!! $x^2+2x-1$.\n# So is ''this'' $\sum_i$.\n\n")
  end
  
  test "Parser" do
    parser = QuadbaseParser.new
    
    assert_nothing_raised {
      out = parser.parse("This is a short paragraph $x^2$.\n\n");
      assert_equal out[:paragraphs].size, 1
    }
    
    assert_nothing_raised {
      out = parser.parse("This is a short paragraph $x^2$.\n");
      assert_equal out[:paragraphs].size, 1
    }
    
    assert_nothing_raised {
      parser.parse("This is {img:myfile} a short paragraph $x^2$.\n\nFollowed !!by a ''multi-line''!!\n paragraph\n\nhi \n\n* And bullet 1\n*Bullet 2\n\n")
    }
  end
  
end

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class TestImageTagMaker
  def make_tag(image_name) 
    "<img src=\"#{image_name}.png\">"
  end
end

class QuadbaseHtmlTransformerTest < ActiveSupport::TestCase

  test "fun" do
    input = "This is {img:myfile} a short paragraph $x^2$.\n\nFollowed !!by a ''multi-line''!!\n paragraph\n\nhi \n\n* And bullet 1\n*Bullet 2 with math $x^2$ and !!bold!!.\n\n"
    expected1 = '{:paragraphs=>
  [{:paragraph=>
     [{:text=>"This is "@0},
      {:image=>{:filename=>"myfile"@13}},
      {:text=>" a short paragraph "@20},
      {:math=>"$x^2$"@39},
      {:text=>"."@44}]},
   {:paragraph=>
     [{:text=>"Followed "@47},
      {:bold=>[{:text=>"by a "@58}, {:italic=>[{:text=>"multi-line"@65}]}]},
      {:text=>" paragraph"@80}]},
   {:paragraph=>[{:text=>"hi "@92}]},
   {:paragraph=>
     [{:bulleted_list=>
        [{:bullet=>"And bullet 1"@99}, {:bullet=>"Bullet 2"@113}]}]}]}'
    expected2 = "<p>This is <center><img src=\"myfile.png\"></center> a short paragraph $x^2$.</p>\n<p>Followed <b>by a  <i>multi-line</i></b> paragraph</p>\n<p>hi </p>\n<p><ul><li>And bullet 1</li>\n<li>Bullet 2 with math $x^2$ and <b>bold</b>.</li></ul></p>"
    parser = QuadbaseParser.new
    output1 = parser.parse(input)
    
    TagHelper.image_tag_maker = TestImageTagMaker.new
    
    output2 = QuadbaseHtmlTransformer.new.apply(output1)
    assert_equal output2.class.name, "String"
   # assert_equal_string_strip_whitespace expected1, output1.inspect()
    assert_equal expected2, output2.to_s()
  end

 
end

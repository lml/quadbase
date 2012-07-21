require 'builder'
xml = Builder::XmlMarkup.new

xml.instruct!
xml.Document{
  xml.item{
    xml.presentation{
      xml.material{
        xml.mattext("texttype" => "text/html") {
          xml.cdata!(@question.content_html.html_safe)
        }
      }
      xml.response_lid{
        xml.render_choice{
          @question.answer_choices.each_index do |ac|
            xml.response_label("ident" => "A" + ac.to_s){
              xml.material{
                xml.mattext("texttype" => "text/html"){
                  xml.cdata!(@question.answer_choices[ac].content_html.html_safe)
                }
              }
            }
          end
        }
      }
    }
    xml.resprocessing{
      @question.answer_choices.each_index do |ac|
        xml.respcondition{
          xml.conditionvar{
            xml.varequal "A" + ac.to_s
          }
          xml.setvar(@question.answer_choices[ac].credit,"varname" => "que_score", "action" => "Add"
          )
        }
      end
    }
  }
}

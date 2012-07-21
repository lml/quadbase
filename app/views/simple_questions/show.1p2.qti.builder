require 'builder'
xml = Builder::XmlMarkup.new

xml.instruct!
xml.Document{
  xml.item{
    xml.presentation{
      xml.material{
        xml.mattext(
          @question.content_html,
          "texttype" => "text/html"
        )
      }
      xml.response_lid{
        xml.render_choice{
          @question.answer_choices.each { |ac|
            xml.response_label{
              xml.material{
                xml.mattext(
                  ac.content_html,
                  "texttype" => "text/html"
                )
              }              
            }
          }
        }
      }     
    }
    xml.resprocessing{}
  }
}

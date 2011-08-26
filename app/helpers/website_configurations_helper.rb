# Copyright (c) 2011 Rice University.  All rights reserved.

module WebsiteConfigurationsHelper

  def value_html_tag_for(configuration)
    case configuration.value_type
    when "boolean"
      check_box_tag configuration.name, "1", configuration.value
    when "text"
      text_field_tag configuration.name, configuration.value
    end
  end

  def value_label_for(configuration)
    case configuration.value_type
    when "boolean"
      tf_to_yn(configuration.value)
    when "text"
      configuration.value
    end
  end

end

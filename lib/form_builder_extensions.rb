# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.


class ActionView::Helpers::FormBuilder

  STANDARD_DATETIME_FORMAT ||= "%m/%d/%Y %l:%M %p"

  # Creates a text field set up for datetimes
  def datetime_text_field(name, options={})
    value = @object.send(name)
    options[:value] ||= value.nil? ? "" : value.strftime(STANDARD_DATETIME_FORMAT)
    
    new_classes = "datetime_field date_time_picker"
    
    options[:class] ||= options[:class].nil? ? 
                        new_classes : 
                        options[:class] + " " + new_classes
                        
    text_field(name, options)
  end
  
end

module ActionView::Helpers::FormTagHelper 
  
  def datetime_text_field_tag(name, value=nil, options={})
     new_classes = "datetime_field date_time_picker"

     options[:class] ||= options[:class].nil? ? 
                         new_classes : 
                         options[:class] + " " + new_classes

     text_field_tag(name, value, options)
   end
end

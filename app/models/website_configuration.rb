# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class WebsiteConfiguration < ActiveRecord::Base

  # Format: {"name" => [value, "value_type"], "name" => [value, "value_type"]}
  @@defaults = {
                  "in_maintenance" => [false, "boolean"],
                  "use_mathjax_cdn" => [true, "boolean"],
                  "home_highlighted_questions" => ["", "text"]
               }

  validates_uniqueness_of :name
  validates_presence_of :value_type

  attr_accessible :value

  def self.defaults
    @@defaults
  end

  def self.get_value(name)
    configuration = WebsiteConfiguration.find_by_name(name)
    
    # Check if we need to lazily instantiate this parameter
    if configuration.nil?
      default = @@defaults[name]
      raise IllegalArgument if default.nil?
      configuration = WebsiteConfiguration.new
      configuration.name = name
      configuration.value = default[0]
      configuration.value_type = default[1]
      configuration.save!
    end
    
    case configuration.value_type
    when "boolean"
      !configuration.value.blank? && configuration.value != "f" &&\
        configuration.value != "false" && configuration.value != "0"
    else
      configuration.value
    end
  end

  #############################################################################
  # Access control methods
  #############################################################################

  def self.can_be_read_by?(user)
    !user.is_anonymous? && user.is_administrator?
  end
  
  def self.can_be_updated_by?(user)
    !user.is_anonymous? && user.is_administrator?
  end
end

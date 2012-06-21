# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module ContentParseAndCache

  # We have to put these meta function calls on the ActiveRecord class including
  # this module
  # http://handyrailstips.com/tips/14-drying-up-your-ruby-code-with-modules
  def self.included( base )
    base.send :validate, :check_for_no_html
    base.send :validate, :parse_succeeds
    base.send :before_save, :cache_html
  end

  # Set to true on tests where the content of a question or solution should be parsed.
  # Then set to false afterwards.
  mattr_accessor :enable_test_parser
  
  def refresh_cached_html!
    parse_succeeds(true)
    cache_html
    self.update_attribute(:content_html, content_html)
  end

protected

  attr_accessor :parse_tree

  def content_unchanged?
    # content_changed only works when the record is already in the DB
    !self.id.nil? && !content_changed?
  end


  def check_for_no_html
    return if content_unchanged? ||
              (Rails.env.test? && !ContentParseAndCache.enable_test_parser)
                
    
    if (content != ActionController::Base.helpers.strip_tags(content))
      errors.add(:content, "cannot contain HTML.")
      false
    end
  end

  def parse_succeeds(force=false)
    if content.blank?
      self.content_html = ''
      return
    end
    return if !force &&
              (content_unchanged? ||
               (Rails.env.test? && !ContentParseAndCache.enable_test_parser))
    
    parser = QuadbaseParser.new
    begin
      self.parse_tree = parser.parse(content)
    rescue Parslet::ParseFailed => error
      # logger.debug {"Parsing failed " + parser.error_tree.inspect.to_s}
      errors.add(:content, "contains a formatting error.")
      false
    end
  end

  def cache_html
    return if parse_tree.nil? ||
              (Rails.env.test? && !ContentParseAndCache.enable_test_parser)
    image_tag_maker = self.respond_to?('get_image_tag_maker') ? 
                      self.get_image_tag_maker : nil
    TagHelper.image_tag_maker = image_tag_maker
    transformer = QuadbaseHtmlTransformer.new

    transformed_tree = transformer.apply(parse_tree)
    self.content_html = transformed_tree.force_encoding("UTF-8")
    # logger.debug {"SimpleQuestion::cache_html: "  + transformed_tree.inspect.to_s}
  end

end

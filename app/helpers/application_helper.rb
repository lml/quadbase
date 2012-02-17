# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'digest/md5'

module ApplicationHelper
  def trash_icon
    image_tag("trash.gif", {:border => 0, :alt => "Delete", :title => "Delete"})
    #{}"<span class=\"trashIcon\"></span>".html_safe
  end

  def x_icon
    image_tag("black_x_v1.png", {:border => 0, :alt => "Remove", :title => "Remove"})
    #{}"<span class=\"xIcon\"></span>".html_safe
  end
  
  def edit_icon(dom_id="edit_img")
    image_tag("edit.gif", {:id => dom_id, :border => 0, :alt => "Edit", :title => "Edit"})
    #{}"<span class=\"editIcon\"></span>".html_safe
  end
  
  def show_icon
    image_tag("show.gif", {:border => 0, :alt => "Show Details", :title => "Show Details"})
    #"<div class=\"showIcon\" title=\"Show Details\"></div>".html_safe
  end
  
  def up_icon
    image_tag("up_arrow_head.png", {:border => 0, :alt => "Move Down", :title => "Move Down"})
  end
  
  def down_icon
    image_tag("down_arrow_head.png", {:border => 0, :alt => "Move Down", :title => "Move Down"})
  end
  
  def check_icon
    image_tag("check_icon_v1.png", {:border => 0, :alt => "Yes / Check", :title => "Yes / Check"})
  end
  
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  # Options:
  #    options[:partial_name] - way to override the partial name (e.g. to include
  #                             a controller).
  def link_to_add_fields(name, f, association, elem_to_append_to, locals={}, options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder| 
      options[:partial_name] ||= association.to_s.singularize + "_fields"
      render(options[:partial_name], ({:f => builder}.merge(locals)))
    end
    link_to_function(name, "add_fields(\"#{elem_to_append_to}\", " + 
                                      "\"#{association}\", " + 
                                      "\"#{escape_javascript(fields)}\")")
  end
  
  def full_name_link(user)
    text = (user_signed_in? && current_user.id == user.id) ? "Me" : user.full_name
    link_to text, user
  end
  
  
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
  
  def tf_to_yn(bool)
    bool ? "Yes" : "No"
  end
  
  def is_page_secure?
    request.url =~ %r{(\w+):\/\/}
    "https" == $1.downcase
  end
  
  def link_to_secure_page(link_text)
    request.url =~ %r{:\/\/([\w\-\.]+)(:\d*)?\/(.*)}
    link_to(link_text, "https://" + $1 + ":20000/" + $3)
  end
  
  def standard_sentence_for_secure_link
    if !is_page_secure?
      ("Prefer a <b>secure</b> version of this page so you don't send your password in the clear?  " + 
      link_to_secure_page("Click here") + ".").html_safe
    end
  end
  
  def auth_only(text)
    user_signed_in? ? text : "[ hidden ]"
  end

  def admin_only(text)
    user_is_admin? ? text : "[ hidden ]"
  end
  
  def trim(text, num_characters)
    text.length <= num_characters ? text : "#{text[0..num_characters-4-1]} ..."
  end
  
  def is_tab_selected?(which)
    !@selected_tab.nil? && which == @selected_tab
  end
  
  def pageHeading(heading_text, title_text="", options={})
    options[:take_out_quadbase_in_page_title] ||= true
    title_text = heading_text if title_text.empty?
    @page_title = String.new(title_text)
    @page_title.sub!("Quadbase","").strip! if @page_title.include?("Quadbase") && options[:take_out_quadbase_in_page_title]
    content_tag("div",heading_text, {"id"=>"pageHeading"} ) if !heading_text.empty?
  end
  
  def submit_classes
    "ui-state-default ui-corner-all submitButton"
  end

  def hide_email(email)
    domain = email.split('@')[1]
    if domain.nil?
      return '***'
    end
    return '***@' + domain
  end
  
  # part is a QuestionPart.  This method will preferentially return the
  # edit path for the question if it is unpublished, otherwise, the 
  # question part show path
  def part_edit_or_show_path(part, try_edit_view)
    try_edit_view && !part.child_question.is_published? ?
    edit_question_path(part.child_question) :
    question_show_part_path(part.multipart_question, part.order)
  end
  
  def commentable_name(comment_thread)
    case comment_thread.commentable_type
    when 'Question'
      "question " + question_id_text(comment_thread.commentable)
    when 'Solution'
      comment_thread.commentable.creator.full_name + "'s solution to question " + \
      question_id_text(comment_thread.commentable.question)
    when 'Project'
      comment_thread.commentable.name
    when 'Message'
      "message: " + comment_thread.commentable.subject
    end
  end
  
  def questions_id_text(questions)
    questions.collect { |q| question_id_text(q) }.join(", ")
  end
  
  def question_id_text(question, show_draft_detail=false)
    question.is_published? ?
      "q. #{question.number}, v. #{question.version}" :
      "q. #{question.number}, DRAFT#{" " + question.id if show_draft_detail}"
  end
  
  def please_wait_js
    '$(this).blur().hide().parent().append("Please wait");'
  end
  
  def ej(text)
    escape_javascript(text)
  end
  
  def gravatar_hash(user)
    Digest::MD5.hexdigest(user.email)
  end
  
  def gravatar_url_for(user, options = {})
    options[:secure] ||= request.ssl?
    options[:size] ||= 50
    
    hash = gravatar_hash(user)
    base = options[:secure] ? "https://secure" : "http://www"
      
    "#{base}.gravatar.com/avatar/#{hash}?s=#{options[:size]}"
  end
  
  def gravatar_image(user, options = {}) 
    image_tag(gravatar_url_for(user, options), 
              { :alt => "User Avatar", 
                :title => "User Avatar",
                :border => 1 })
  end
  
  def base_class(object)
    object.respond_to?(:base_class) ? object.base_class : object.class
  end
  
  def link_to_help(topic, text="", options={})
    @include_help_dialog = true
    @include_mathjax = true if options[:include_mathjax]
    
    @options = options
    
    link_to (text.blank? ? image_tag('help_button_v2.png') : text), 
            topic_help_path(topic, :options => options), 
            :remote => true
  end
  
  def none_row(table_id, items_array, num_columns)
    output = "<tr id=\"#{table_id}_none_row\""
    output << " style=\"display:none\"" if !items_array.empty?
    output << "><td colspan=\"#{num_columns}\"><center>None</center></td></tr>"
    output.html_safe
  end
  
  
end

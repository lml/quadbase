# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module JqueryHelper
  def display_flash(scroll = true)
    # Override scroll in the case where there's nothing to see
    scroll = scroll && !flash[:alert].blank? && !flash[:notice].blank?
    
    output = '$("#attention").html("' +
             escape_javascript(render :partial => 'shared/attention') +
             '");'
    output << ' scrollTo(0,0);' if scroll
    flash.discard
    output.html_safe
  end

  def update_inbox_count
    return #   # INBOX COUNTS ARE CURRENTLY INACCURATE AND HAVE BEEN DEACTIVATED
    # ('$("#inbox_tab").replaceWith("' +
    #   escape_javascript(render :partial => 'shared/inbox_tab') + '");').html_safe
  end

  def update_multipart_nav(multipart_question, current_question, on_edit_view)
    ('$("#multipartNav").replaceWith("' +
      escape_javascript(render :partial => 'layouts/multipart_nav',
                               :locals => { :multipart_question => multipart_question,
                                            :current_question => current_question,
                                            :on_edit_view => on_edit_view }) +
      '");').html_safe
  end

  def hide_none(row_id = "")
    ('$("#' + row_id + 'none_row").hide();').html_safe
  end

  def show_none(row_id = "")
    ('$("#' + row_id + 'none_row").show();').html_safe
  end

  # This function is used to make MathJax re-process the page after we update the contents
  # using javascript. Unless it is called after each update, math won't display properly.
  def reload_mathjax(element_id="")
    ('MathJax.Hub.Queue(["Typeset", MathJax.Hub, document.getElementById("' +
            element_id + '")]);').html_safe
  end

  def message_dialog(title=nil, options={}, &block)
    specified_dialog("message", title, options, &block)
  end
  
  def specified_dialog(name=nil, title=nil, options={}, &block)
    @name ||= name
    @title ||= title
    @options = options
    @body = capture(&block)
    render :template => 'shared/specified_dialog'
  end

end

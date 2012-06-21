# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class DigestNotifier < DigestMailer

  helper :application


    def digest_email(msg)
    setup_variables(msg)
    
    mal(:bcc => @digest_subscribers.reject{ |as| a == @creator }.collect { |as| as.email },
        :subject => "Digest Email",
        :message => :message.to_s + @creator.full_name +
                       (@is_message ? " sent you a message: " + @commentable.subject :
                       " has commented on a thread to which you subscribe")).delay
                       
   end 
   
private


  def setup_variables(comment)
    @comment = comment
    @creator = comment.creator
    @comment_thread = comment.comment_thread
    @commentable = @comment_thread.commentable.becomes(
                     Kernel.const_get(@comment_thread.commentable_type))
    @digest_subscribers = User.digest_subscribers_for(@digest).active_users
    @is_message = @comment_thread.commentable_type == 'Message'
  end

  
end

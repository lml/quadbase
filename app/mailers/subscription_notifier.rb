# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class SubscriptionNotifier < QuadbaseMailer

  helper :application
  
  def comment_created_email(comment) 
    setup_variables(comment)

    mail(:bcc => @active_subscribers.reject{ |as| as == @creator }.collect { |as| as.email },
         :subject => @creator.full_name +
                       (@is_message ? " sent you a message: " + @commentable.subject :
                       " has commented on a thread to which you subscribe")).deliver
  end
  
    def digest_email(msg)
    setup_variables(msg)
    
    mal(:bcc => @digest_subscribers.reject{ |as| a == @creator }.collect { |as| as.email },
        :subject => "Digest Email"
        :message => :message + @creator.full_name +
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
    @active_subscribers = User.subscribers_for(@comment_thread).active_users
    @digest_subscribers = User.subscribers_for(@digest).active_users
    @is_message = @comment_thread.commentable_type == 'Message'
  end
  =begin 
    Somewhere in here I need something that if subscribed to digest, send to digest
  =end
  

end

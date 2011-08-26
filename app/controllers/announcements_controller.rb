# Copyright (c) 2011 Rice University.  All rights reserved.

class AnnouncementsController < AdminController

  # GET /announcements
  def index
    @announcements = Announcement.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /announcements/1
  def show
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /announcements/new
  def new
    @announcement = Announcement.new
    @announcement.user = present_user

    raise SecurityTransgression unless present_user.can_create?(@announcement)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /announcements
  def create
    @announcement = Announcement.new(params[:announcement])
    @announcement.user = present_user

    raise SecurityTransgression unless present_user.can_create?(@announcement)

    respond_to do |format|
      if @announcement.save
        AnnouncementNotifier.announcement_email(@announcement)
        format.html { redirect_to(announcements_path, :notice => 'Announcement was successfully sent.') }
      else
        @errors = @announcement.errors
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /announcements/1
  def destroy
    @announcement = Announcement.find(params[:id])

    raise SecurityTransgression unless present_user.can_destroy?(@announcement)

    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to(announcements_url) }
    end
  end
end

class MyPagesController < ApplicationController
  def show
    @registrations = Current.user.registrations.includes(:event).order("events.starts_at")
  end
end

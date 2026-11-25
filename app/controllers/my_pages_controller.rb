class MyPagesController < ApplicationController
  def show
    @registrations = Current.user.registrations.registered.includes(:event).order("events.starts_at")
  end
end

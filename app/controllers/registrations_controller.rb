class RegistrationsController < ApplicationController
  before_action :set_event

  def create
    @event.registrations.create!(user: Current.user, status: :registered)
    redirect_to @event, notice: "参加登録しました。"
  end

  def destroy
    registration = @event.registrations.registered.find_by!(user: Current.user)
    registration.cancelled!
    redirect_to @event, notice: "参加をキャンセルしました。", status: :see_other
  end

  private
    def set_event
      @event = Event.find(params[:event_id])
    end
end

class RegistrationsController < ApplicationController
  before_action :set_event

  def create
    registration = @event.register(Current.user)

    if registration.errors.any?
      redirect_to @event, alert: registration.errors.full_messages.to_sentence
    else
      redirect_to @event, notice: "参加登録しました。"
    end
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

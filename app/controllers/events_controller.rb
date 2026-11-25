class EventsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_event, only: %i[show edit update destroy]
  before_action :require_organizer, only: %i[edit update destroy]

  def index
    @events = Event.upcoming
  end

  def show
    @registration = @event.registration_for(Current.user) if authenticated?
  end

  def new
    @event = Event.new
  end

  def create
    @event = Current.user.organized_events.build(event_params)

    if @event.save
      redirect_to @event, notice: "イベントを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "イベントを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: "イベントを削除しました。", status: :see_other
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def require_organizer
      redirect_to @event, alert: "主催者のみ操作できます。" unless @event.organized_by?(Current.user)
    end

    def event_params
      params.expect(event: %i[title description starts_at capacity registration_deadline])
    end
end

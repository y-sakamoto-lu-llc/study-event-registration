require "rails_helper"

RSpec.describe Event, type: :model do
  describe "バリデーション" do
    it "タイトル・開催日時・定員があれば有効" do
      expect(build(:event)).to be_valid
    end

    it "タイトルがなければ無効" do
      expect(build(:event, title: "")).not_to be_valid
    end

    it "定員は1以上の整数" do
      expect(build(:event, capacity: 0)).not_to be_valid
      expect(build(:event, capacity: 1.5)).not_to be_valid
    end
  end

  describe ".upcoming" do
    it "これから開催するイベントだけを開催日時の早い順に返す" do
      later = create(:event, starts_at: 5.days.from_now)
      sooner = create(:event, starts_at: 1.day.from_now)
      create(:event, starts_at: 1.day.ago, registration_deadline: 2.days.ago)

      expect(Event.upcoming).to eq [ sooner, later ]
    end
  end

  describe "#participants" do
    it "キャンセルした人は含めない" do
      event = create(:event)
      registered = create(:registration, event: event).user
      create(:registration, event: event, status: :cancelled)

      expect(event.participants).to contain_exactly(registered)
    end
  end

  describe "#organized_by?" do
    it "主催者なら true を返す" do
      event = create(:event)
      expect(event.organized_by?(event.organizer)).to be true
      expect(event.organized_by?(create(:user))).to be false
    end
  end
end

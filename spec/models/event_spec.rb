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

  describe "#full?" do
    # AC-1
    it "登録者数が定員に達していれば true" do
      event = create(:event, capacity: 2)
      create_list(:registration, 2, event: event)

      expect(event.full?).to be true
    end

    # AC-1
    it "登録者数が定員未満なら false" do
      event = create(:event, capacity: 2)
      create(:registration, event: event)

      expect(event.full?).to be false
    end

    # AC-1, AC-4
    it "キャンセルした人は登録者数に数えない" do
      event = create(:event, capacity: 2)
      create(:registration, event: event)
      create(:registration, event: event, status: :cancelled)

      expect(event.full?).to be false
    end
  end

  describe "#accepting_registrations?" do
    let(:deadline) { Time.zone.local(2026, 12, 10, 18, 0, 0) }
    let(:starts_at) { Time.zone.local(2026, 12, 12, 19, 0, 0) }

    context "申込締切があるとき" do
      let(:event) { create(:event, starts_at: starts_at, registration_deadline: deadline) }

      # AC-2
      it "締切前なら true" do
        travel_to(deadline - 1.hour) { expect(event.accepting_registrations?).to be true }
      end

      # AC-2
      it "締切時刻ちょうどなら true" do
        travel_to(deadline) { expect(event.accepting_registrations?).to be true }
      end

      # AC-2
      it "締切を1秒でも過ぎたら false" do
        travel_to(deadline + 1.second) { expect(event.accepting_registrations?).to be false }
      end
    end

    context "申込締切がないとき" do
      let(:event) { create(:event, starts_at: starts_at, registration_deadline: nil) }

      # AC-2
      it "開催日時の前なら true" do
        travel_to(starts_at - 1.second) { expect(event.accepting_registrations?).to be true }
      end

      # AC-2
      it "開催時刻ちょうどなら true" do
        travel_to(starts_at) { expect(event.accepting_registrations?).to be true }
      end

      # AC-2
      it "開催日時を過ぎたら false" do
        travel_to(starts_at + 1.second) { expect(event.accepting_registrations?).to be false }
      end
    end
  end

  describe "#register" do
    let(:user) { create(:user) }

    # AC-1
    it "空きがあり締切前なら登録済みの登録を作る" do
      event = create(:event, capacity: 1)

      registration = event.register(user)

      expect(registration).to be_persisted
      expect(registration).to be_registered
      expect(event.participants).to contain_exactly(user)
    end

    # AC-1
    it "満席なら登録せず「満席です」を返す" do
      event = create(:event, capacity: 1)
      create(:registration, event: event)

      registration = nil
      expect { registration = event.register(user) }.not_to change(Registration, :count)
      expect(registration).not_to be_persisted
      expect(registration.errors[:base]).to include "満席です"
    end

    # AC-2
    it "締切を過ぎていたら登録せず「申込は締め切りました」を返す" do
      deadline = Time.zone.local(2026, 12, 10, 18, 0, 0)
      event = create(:event, starts_at: deadline + 2.days, registration_deadline: deadline)

      travel_to(deadline + 1.second) do
        registration = nil
        expect { registration = event.register(user) }.not_to change(Registration, :count)
        expect(registration).not_to be_persisted
        expect(registration.errors[:base]).to include "申込は締め切りました"
      end
    end

    # AC-2
    it "締切時刻ちょうどなら登録できる" do
      deadline = Time.zone.local(2026, 12, 10, 18, 0, 0)
      event = create(:event, starts_at: deadline + 2.days, registration_deadline: deadline)

      travel_to(deadline) do
        expect(event.register(user)).to be_registered
      end
    end

    # AC-3
    it "すでに登録済みの人がもう一度登録しても登録は1件のまま" do
      event = create(:event)
      event.register(user)

      expect { event.register(user) }.not_to change(Registration, :count)
      expect(event.registrations.where(user: user).count).to eq 1
    end

    # AC-3
    it "キャンセルした人がもう一度登録すると、新しい行を作らずに同じ登録を登録済みに戻す" do
      event = create(:event)
      cancelled = create(:registration, event: event, user: user, status: :cancelled)

      registration = nil
      expect { registration = event.register(user) }.not_to change(Registration, :count)
      expect(registration.id).to eq cancelled.id
      expect(cancelled.reload).to be_registered
    end

    # AC-3
    it "キャンセルした人でも満席なら登録済みに戻さない" do
      event = create(:event, capacity: 1)
      cancelled = create(:registration, event: event, user: user, status: :cancelled)
      create(:registration, event: event)

      registration = event.register(user)

      expect(registration.errors[:base]).to include "満席です"
      expect(cancelled.reload).to be_cancelled
    end

    # AC-3
    it "キャンセルした人でも締切後なら登録済みに戻さない" do
      deadline = Time.zone.local(2026, 12, 10, 18, 0, 0)
      event = create(:event, starts_at: deadline + 2.days, registration_deadline: deadline)
      cancelled = create(:registration, event: event, user: user, status: :cancelled)

      travel_to(deadline + 1.second) do
        registration = event.register(user)

        expect(registration.errors[:base]).to include "申込は締め切りました"
        expect(cancelled.reload).to be_cancelled
      end
    end

    # AC-4
    it "誰かがキャンセルすると枠が1つ空き、別の人が登録できる" do
      event = create(:event, capacity: 1)
      other = create(:registration, event: event)
      expect(event.register(user).errors[:base]).to include "満席です"

      other.cancelled!

      expect(event.register(user)).to be_registered
      expect(event.participants).to contain_exactly(user)
    end
  end
end

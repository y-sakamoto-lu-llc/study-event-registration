require "rails_helper"

RSpec.describe Registration, type: :model do
  it "作成時の状態は登録済み" do
    registration = create(:registration)
    expect(registration).to be_registered
  end

  it "キャンセルすると状態がキャンセルになる" do
    registration = create(:registration)
    registration.cancelled!
    expect(registration.reload).to be_cancelled
  end

  describe "重複登録の禁止" do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    # AC-3
    it "同じ人が同じイベントに2件目の登録を作ることはできない" do
      create(:registration, user: user, event: event)

      expect(build(:registration, user: user, event: event)).not_to be_valid
    end

    # AC-3
    it "1件目がキャンセル済みでも、同じイベントに2件目の登録は作れない" do
      create(:registration, user: user, event: event, status: :cancelled)

      expect(build(:registration, user: user, event: event)).not_to be_valid
    end

    # AC-3
    it "バリデーションを飛ばしても、データベースが2件目の登録を拒む" do
      create(:registration, user: user, event: event)

      expect {
        build(:registration, user: user, event: event).save!(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    # AC-3
    it "同じ人でも別のイベントなら登録できる" do
      create(:registration, user: user, event: event)

      expect(build(:registration, user: user, event: create(:event))).to be_valid
    end
  end

  describe "キャンセル" do
    # AC-4
    it "申込締切を過ぎてもキャンセルできる" do
      deadline = Time.zone.local(2026, 12, 10, 18, 0, 0)
      event = create(:event, starts_at: deadline + 2.days, registration_deadline: deadline)
      registration = create(:registration, event: event)

      travel_to(deadline + 1.day) do
        registration.cancelled!
        expect(registration.reload).to be_cancelled
        expect(event.participants).to be_empty
      end
    end
  end
end

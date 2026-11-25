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
end

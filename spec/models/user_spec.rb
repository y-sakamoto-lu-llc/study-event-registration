require "rails_helper"

RSpec.describe User, type: :model do
  it "名前とメールアドレスがあれば有効" do
    expect(build(:user)).to be_valid
  end

  it "名前がなければ無効" do
    expect(build(:user, name: "")).not_to be_valid
  end

  it "メールアドレスは前後の空白を除いて小文字にそろえる" do
    user = create(:user, email_address: " Taro@Example.COM ")
    expect(user.email_address).to eq "taro@example.com"
  end

  it "同じメールアドレスは登録できない" do
    create(:user, email_address: "taro@example.com")
    expect(build(:user, email_address: "taro@example.com")).not_to be_valid
  end
end

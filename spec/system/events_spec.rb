require "rails_helper"

RSpec.describe "イベント", type: :system do
  let(:organizer) { create(:user, name: "主催者") }
  let!(:event) { create(:event, organizer: organizer, title: "Rails 勉強会", capacity: 10) }

  it "ログインしていなくても一覧と詳細を見られる" do
    visit root_path
    expect(page).to have_content "Rails 勉強会"
    expect(page).to have_content "0 / 10 人"

    click_link "Rails 勉強会"
    expect(page).to have_content "ログインすると参加登録できます。"
  end

  it "参加登録してからキャンセルできる" do
    user = create(:user, name: "参加者")
    sign_in_as user

    visit event_path(event)
    click_button "参加する"
    expect(page).to have_content "参加登録しました。"
    expect(page).to have_content "参加者（1 人）"

    visit my_page_path
    expect(page).to have_link "Rails 勉強会"

    visit event_path(event)
    click_button "キャンセルする"
    expect(page).to have_content "参加をキャンセルしました。"
    expect(page).to have_content "参加者（0 人）"
  end

  it "イベントを作成できる" do
    sign_in_as organizer

    visit new_event_path
    fill_in "タイトル", with: "RSpec 勉強会"
    fill_in "開催日時", with: 7.days.from_now.strftime("%Y-%m-%dT19:00")
    fill_in "定員", with: 20
    click_button "イベントを作成する"

    expect(page).to have_content "イベントを作成しました。"
    expect(page).to have_content "RSpec 勉強会"
  end

  it "主催者以外は編集できない" do
    sign_in_as create(:user)

    visit edit_event_path(event)
    expect(page).to have_content "主催者のみ操作できます。"
  end
end

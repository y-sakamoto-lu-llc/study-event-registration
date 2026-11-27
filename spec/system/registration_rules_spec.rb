require "rails_helper"

RSpec.describe "参加登録のルール", type: :system do
  let(:user) { create(:user, name: "参加者") }

  # AC-1
  it "満席のイベントで「参加する」を押すと「満席です」と表示され、登録されない" do
    event = create(:event, title: "満席の勉強会", capacity: 1)
    create(:registration, event: event, user: create(:user, name: "先に登録した人"))
    sign_in_as user

    visit event_path(event)
    click_button "参加する"

    expect(page).to have_content "満席です"
    expect(page).not_to have_content "参加登録しました。"
    expect(page).to have_content "参加者（1 人）"
    expect(page).not_to have_css "li", text: "参加者"
  end

  # AC-2
  it "申込締切を過ぎたイベントで「参加する」を押すと「申込は締め切りました」と表示され、登録されない" do
    event = create(:event, title: "締切済みの勉強会", starts_at: 3.days.from_now, registration_deadline: 1.hour.ago)
    sign_in_as user

    visit event_path(event)
    click_button "参加する"

    expect(page).to have_content "申込は締め切りました"
    expect(page).not_to have_content "参加登録しました。"
    expect(page).to have_content "参加者（0 人）"
  end

  # AC-3 キャンセルした人が、空きがあり締切前のイベントにもう一度登録できること（画面の表示）と、
  #      登録し直しても登録が1件のままであることを確かめる。
  #      満席・締切後には再登録できないことは、モデルスペック（Event#register）で確かめる。
  it "キャンセルした人は、空きがあり締切前ならもう一度登録でき、登録は1件のまま" do
    event = create(:event, title: "Rails 勉強会", capacity: 10)
    sign_in_as user

    visit event_path(event)
    click_button "参加する"
    click_button "キャンセルする"
    expect(page).to have_content "参加をキャンセルしました。"

    click_button "参加する"
    aggregate_failures do
      expect(page).to have_content "参加登録しました。"
      expect(page).to have_content "参加登録済みです。"
      expect(page).to have_content "参加者（1 人）"
      expect(event.registrations.where(user: user).count).to eq 1
    end
  end

  # AC-4
  it "申込締切を過ぎてもキャンセルでき、登録者数から外れる" do
    event = create(:event, title: "Rails 勉強会", starts_at: 3.days.from_now, registration_deadline: 1.day.from_now)
    create(:registration, event: event, user: user)
    sign_in_as user

    travel_to(2.days.from_now) do
      visit event_path(event)
      click_button "キャンセルする"

      expect(page).to have_content "参加をキャンセルしました。"
      expect(page).to have_content "参加者（0 人）"
    end
  end

  # AC-5
  it "マイページでは、キャンセルしたイベントに「キャンセル済み」と表示される" do
    event = create(:event, title: "Rails 勉強会")
    sign_in_as user

    visit event_path(event)
    click_button "参加する"
    click_button "キャンセルする"

    visit my_page_path
    expect(page).to have_link "Rails 勉強会", count: 1
    expect(page).to have_css "li", text: /Rails 勉強会.*キャンセル済み/
  end

  # AC-5
  it "マイページでは、キャンセルしてから登録し直したイベントが最新の状態で1件だけ表示される" do
    event = create(:event, title: "Rails 勉強会")
    sign_in_as user

    visit event_path(event)
    click_button "参加する"
    click_button "キャンセルする"
    click_button "参加する"

    visit my_page_path
    expect(page).to have_link "Rails 勉強会", count: 1
    expect(page).not_to have_content "キャンセル済み"
  end
end

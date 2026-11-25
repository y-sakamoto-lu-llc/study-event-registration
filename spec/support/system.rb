module SystemHelpers
  def sign_in_as(user, password: "password")
    visit new_session_path
    fill_in "メールアドレス", with: user.email_address
    fill_in "パスワード", with: password
    click_button "ログイン"
  end
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.include SystemHelpers, type: :system
end

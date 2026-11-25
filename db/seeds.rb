# Sample data for local development. Run with `bin/rails db:seed`.
# Every user's password is "password".

users = [
  { name: "主催 太郎", email_address: "organizer@example.com" },
  { name: "参加 花子", email_address: "hanako@example.com" },
  { name: "参加 次郎", email_address: "jiro@example.com" },
  { name: "参加 三郎", email_address: "saburo@example.com" },
  { name: "参加 四子", email_address: "shiko@example.com" }
].map do |attrs|
  User.find_or_create_by!(email_address: attrs[:email_address]) do |user|
    user.name = attrs[:name]
    user.password = "password"
  end
end

organizer, *participants = users

topics = %w[Ruby Rails RSpec Hotwire SQL テスト設計 リファクタリング Git セキュリティ パフォーマンス]

20.times do |i|
  starts_at = (i + 1).days.from_now.change(hour: 19)
  event = Event.find_or_create_by!(title: "#{topics[i % topics.size]}勉強会 ##{i + 1}") do |e|
    e.organizer = organizer
    e.description = "#{topics[i % topics.size]}について学ぶ勉強会です。"
    e.starts_at = starts_at
    e.capacity = [ 3, 5, 10, 20 ][i % 4]
    e.registration_deadline = starts_at - 1.day
  end

  participants.first(i % participants.size).each do |user|
    event.registrations.find_or_create_by!(user: user)
  end
end

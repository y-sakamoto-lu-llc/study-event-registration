FactoryBot.define do
  factory :event do
    association :organizer, factory: :user
    sequence(:title) { |n| "勉強会 ##{n}" }
    description { "勉強会の説明です。" }
    starts_at { 3.days.from_now }
    capacity { 10 }
    registration_deadline { 2.days.from_now }
  end
end

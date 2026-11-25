FactoryBot.define do
  factory :registration do
    user
    event
    status { :registered }
  end
end

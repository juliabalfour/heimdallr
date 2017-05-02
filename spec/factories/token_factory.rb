FactoryGirl.define do
  factory :token do
    expires_at { Faker::Date.between(20.minutes.from_now.utc, 1.hour.from_now.utc) }
  end
end

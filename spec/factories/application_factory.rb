FactoryGirl.define do
  factory :application, class: Heimdallr::Application do
    name { Faker::ChuckNorris.fact }
    secret { Digest::SHA256.hexdigest(SecureRandom.uuid).to_s }
    scopes { %w[users:view users:create users:update shibas:all] }
    ip { Faker::Internet.ip_v4_address }

    trait :rsa do
      certificate { OpenSSL::PKey::RSA.generate(2048).to_s }
    end
  end
end

FactoryGirl.define do
  factory :application do
    name { Faker::ChuckNorris.fact }
    secret { Digest::SHA256.hexdigest(SecureRandom.uuid).to_s }
    scopes { %w[users:create users:update shibas:all] }
    ip { Faker::Internet.ip_v4_address }

    trait :rsa do
      algorithm %w[RS256 RS384 RS512].sample
      certificate { OpenSSL::PKey::RSA.generate(2048).to_s }
    end
  end
end

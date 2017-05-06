module Heimdallr
  describe DeleteExpiredTokens do
    let(:application) do
      CreateApplication.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode',
        algorithm: 'RS256'
      ).call
    end

    before do
      # These tokens should be deleted
      CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 15.minutes.ago).call
      CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 18.minutes.ago).call
      CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 1.day.ago).call
      CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 3.days.ago).call

      # These tokens should NOT be deleted
      CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 5.minutes.from_now).call
      CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 2.minutes.ago).call
    end

    it 'deletes expired tokens' do
      expect(DeleteExpiredTokens.new.call).to eq(4)
    end
  end
end

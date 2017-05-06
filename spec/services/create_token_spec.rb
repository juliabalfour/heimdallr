module Heimdallr
  describe CreateToken do
    let(:application) do
      CreateApplication.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode'
      ).call
    end

    it 'creates a new token when an application object is provided' do
      token = CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call
      expect(token).to be_a(String)
    end

    it 'creates a new token when an application ID is provided' do
      token = CreateToken.new(application: application.id, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call
      expect(token).to be_a(String)
    end

    it 'creates a new token that can be encoded into a string' do
      token = CreateToken.new(application: application, scopes: %w[users:update universe:implode], expires_at: 30.minutes.from_now).call(encode: false)
      expect(token.encode).to be_a(String)
    end

    it 'raises an exception when an unauthorized scope is requested' do
      expect { CreateToken.new(application: application, scopes: 'universe:create', expires_at: 30.minutes.from_now).call }.to raise_error(StandardError)
    end
  end
end

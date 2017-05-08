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

    it 'creates a new token when an application id & secret is provided' do
      token = CreateToken.new(application: { id: application.id, secret: application.secret }, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call
      expect(token).to be_a(String)
    end

    it 'raises an exception when an application id is provided but the secret is not' do
      expect { CreateToken.new(application: { id: application.id }, scopes: 'universe:create', expires_at: 30.minutes.from_now).call }.to raise_error(ArgumentError)
    end

    it 'raises an exception when an application secret is provided but the id is not' do
      expect { CreateToken.new(application: { secret: application.secret }, scopes: 'universe:create', expires_at: 30.minutes.from_now).call }.to raise_error(ArgumentError)
    end

    it 'creates a new token that can be encoded into a string' do
      token = CreateToken.new(application: application, scopes: %w[users:update universe:implode], expires_at: 30.minutes.from_now).call(encode: false)
      expect(token.encode).to be_a(String)
    end

    it 'raises an exception when an unauthorized scope is requested' do
      expect { CreateToken.new(application: application, scopes: 'universe:create', expires_at: 30.minutes.from_now).call }.to raise_error(TokenError)
    end
  end
end

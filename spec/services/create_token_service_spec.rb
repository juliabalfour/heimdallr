module Heimdallr
  describe CreateTokenService do
    let(:application) do
      CreateApplicationService.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode'
      ).call
    end

    it 'creates a new token when an application object is provided' do
      token = CreateTokenService.new(application: application, scopes: %w[users:create universe:implode]).call
      expect(token).to be_a(Auth::Token)
    end

    it 'creates a new token when an application ID is provided' do
      token = CreateTokenService.new(application: application.id, scopes: %w[users:create universe:implode]).call
      expect(token).to be_a(Auth::Token)
    end

    it 'raises an exception when an unauthorized scope is requested' do
      expect { CreateTokenService.new(application: application, scopes: 'universe:create').call }.to raise_error(StandardError)
    end
  end
end

module Heimdallr
  describe CreateApplicationService do
    it 'creates a new application' do
      application = CreateApplicationService.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode'
      ).call

      expect(application).to be_a(Heimdallr::Application)
    end

    it 'raises an exception when the scope argument is invalid' do
      expect do
        CreateApplicationService.new(
          name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
          scopes: 42
        ).call
      end.to raise_error(ArgumentError)
    end
  end
end

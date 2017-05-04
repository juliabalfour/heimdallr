module Heimdallr
  describe CreateApplicationService do
    context 'using the HMAC256 algorithm' do
      subject do
        CreateApplicationService.new(
          name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
          scopes: 'users:create users:update tokens:delete universe:implode',
          algorithm: 'HS256'
        ).call
      end

      it { expect(subject).to be_a(Application) }

      it 'generates a secret value' do
        expect(subject.secret).to be_a(String)
      end

      it 'does NOT generate a certificate' do
        expect(subject.certificate).to be_nil
      end
    end

    context 'using RSA256 algorithm' do
      subject do
        CreateApplicationService.new(
          name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
          scopes: 'users:create users:update tokens:delete universe:implode',
          algorithm: 'RS256'
        ).call
      end

      it { expect(subject).to be_a(Application) }

      it 'generates a secret value' do
        expect(subject.secret).to be_a(String)
      end

      it 'generates a certificate' do
        expect(subject.certificate).to be_a(String)
      end
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

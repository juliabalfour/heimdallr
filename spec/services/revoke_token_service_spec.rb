module Heimdallr
  describe RevokeTokenService do
    let(:application) do
      CreateApplicationService.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode',
        algorithm: 'RS256'
      ).call
    end

    context 'before the token is revoked' do
      subject { CreateTokenService.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call(encode: false) }

      it 'can be decoded without raising an exception' do
        expect { DecodeTokenService.new(subject.encode).call }.not_to raise_error
      end
    end

    context 'after the token is revoked' do
      subject { CreateTokenService.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call(encode: false) }

      it 'raises an exception when decoding' do
        subject.revoke!
        expect { DecodeTokenService.new(subject.encode).call }.to raise_error(TokenError)
      end
    end
  end
end

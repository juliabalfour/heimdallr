module Heimdallr
  describe DecodeTokenService do
    let(:application) do
      CreateApplicationService.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode',
        algorithm: 'RS256'
      ).call
    end

    context 'with a token that is not expired' do
      let(:token) { CreateTokenService.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call }
      subject { DecodeTokenService.new(token).call }

      it 'decodes a JWT string' do
        expect(subject).to be_a(Token)
      end

      it 'creates an immutable token (frozen)' do
        expect(subject.frozen?).to be_truthy
      end
    end

    context 'with a token that does not exist' do
      subject { CreateTokenService.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call(encode: false) }

      it 'raises an exception when decoding' do
        encoded = subject.encode
        subject.delete

        expect { DecodeTokenService.new(encoded).call }.to raise_error(TokenError)
      end
    end

    context 'with a token that is expired' do
      subject { CreateTokenService.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.ago).call }

      it 'raises an exception when decoding' do
        expect { DecodeTokenService.new(subject).call }.to raise_error(TokenError)
      end
    end

    context 'with a token that not available yet' do
      subject { CreateTokenService.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now, not_before: 5.minutes.from_now).call }

      it 'raises an exception when decoding' do
        expect { DecodeTokenService.new(subject).call }.to raise_error(TokenError)
      end
    end
  end
end

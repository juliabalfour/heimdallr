module Heimdallr
  describe DecodeToken do
    let(:application) do
      CreateApplication.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode',
        algorithm: 'RS256'
      ).call
    end

    context 'with a token that is not expired' do
      let(:token) { CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call }
      subject { DecodeToken.new(token).call }

      it 'decodes a JWT string' do
        expect(subject).to be_a(Token)
      end
    end

    context 'with a token that does not exist' do
      subject { CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now).call(encode: false) }

      it 'raises an exception when decoding' do
        encoded = subject.encode
        subject.delete

        expect { DecodeToken.new(encoded).call }.to raise_error(TokenError)
      end
    end

    context 'with a token that is expired' do
      subject { CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.ago).call }

      it 'has exactly one error' do
        decoded = DecodeToken.new(subject).call
        expect(decoded.token_errors).to match_array ['The provided JWT is expired. Please acquire a new token and try your request again.']
      end
    end

    context 'with a token that not available yet' do
      subject { CreateToken.new(application: application, scopes: %w[users:create universe:implode], expires_at: 30.minutes.from_now, not_before: 5.minutes.from_now).call }

      it 'has exactly one error' do
        decoded = DecodeToken.new(subject).call
        expect(decoded.token_errors).to match_array ['The provided JWT is not valid yet and cannot be used.']
      end
    end
  end
end

module Heimdallr
  module Auth
    describe Token do
      let(:app) { FactoryGirl.create(:application, :rsa) }
      subject do
        Heimdallr.jwt_algorithm = 'RS256'
        token = Token.new
        token.application = app
        token
      end

      context 'encoding and decoding' do
        describe '#encode' do
          it { expect(subject.encode).to be_a(String) }
        end

        describe '.from_string' do
          let(:decoded) { Token.from_string(subject.encode) }

          it { expect(decoded).to be_a(Token) }

          it 'creates an immutable token (frozen)' do
            expect(decoded.frozen?).to be_truthy
          end
        end
      end

      describe '#audience' do
        context 'when an audience is set' do
          before do
            subject.audience = 'Charlotte The Dog'
          end

          it 'has an audience claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.audience).to eq('Charlotte The Dog')
          end
        end

        context 'when an audience is not set' do
          before do
            subject.audience = nil
          end

          it 'does not have an audience claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.audience).to be_nil
          end
        end
      end

      describe '#subject' do
        context 'when a subject is set' do
          before do
            subject.subject = 'Supercalifragilisticexpialidocious'
          end

          it 'has a subject claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.subject).to eq('Supercalifragilisticexpialidocious')
          end
        end

        context 'when a subject is not set' do
          before do
            subject.subject = nil
          end

          it 'does not have a subject claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.subject).to be_nil
          end
        end
      end

      describe '#not_before' do
        context 'when the NBF claim is in the future' do
          before do
            subject.not_before = 1.hour.from_now.to_i
          end

          it 'raises an exception when decoding' do
            expect { Token.from_string(subject.encode) }.to raise_error(TokenError)
          end
        end

        context 'when the NBF claim is in the past' do
          before do
            subject.not_before = 1.hour.ago.to_i
          end

          it 'does not raise an exception when decoding' do
            expect { Token.from_string(subject.encode) }.not_to raise_error
          end
        end
      end

      describe '#jwt_id' do
        context 'when a jwt id is set' do
          before do
            @jwt_id = SecureRandom.uuid
            subject.jwt_id = @jwt_id
          end

          it 'has a jwt id claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.jwt_id).to eq(@jwt_id)
          end
        end

        context 'when a jwt id is not set' do
          before do
            subject.jwt_id = nil
          end

          it 'does not have a jwt id claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.jwt_id).to be_nil
          end
        end
      end

      describe '#issuer' do
        context 'when a issuer is set' do
          before do
            @issuer = "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}"
            subject.issuer = @issuer
          end

          it 'has a issuer claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.issuer).to eq(@issuer)
          end
        end

        context 'when a issuer is not set' do
          before do
            subject.issuer = nil
          end

          it 'does not have a issuer claim after encoding & decoding' do
            decoded = Token.from_string(subject.encode)
            expect(decoded.issuer).to be_nil
          end
        end
      end
    end
  end
end

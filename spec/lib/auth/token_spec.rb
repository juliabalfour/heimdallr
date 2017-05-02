module Heimdallr
  module Auth
    describe Token do
      let(:app) { FactoryGirl.create(:application) }
      subject do
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
            subject.not_before = Faker::Time.between(20.minutes.from_now, 2.days.from_now).to_i
          end

          it 'raises an exception when decoding' do
            expect { Token.from_string(subject.encode) }.to raise_error(TokenError)
          end
        end

        context 'when the NBF claim is in the past' do
          before do
            subject.not_before = Faker::Time.between(2.hours.ago, 10.minutes.ago).to_i
          end

          it 'does not raise an exception when decoding' do
            expect { Token.from_string(subject.encode) }.not_to raise_error
          end
        end
      end
    end
  end
end

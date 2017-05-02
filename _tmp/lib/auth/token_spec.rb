module Heimdallr
  module Auth
    describe Token do

      describe '.decode' do
        context 'with a token that is not expired' do
          let(:token) { Token.new(scope: 'users:add') }
          subject { Token.decode(token_string: token.to_s) }

          it 'is immutable (frozen)' do
            expect(subject.frozen?).to be_truthy
          end

          it 'contains the scope `users:add` inside data' do
            expect(subject.data).to eq(scope: 'users:add')
          end
        end

        context 'with a token that expired 2 weeks ago' do
          let(:token) { Token.new(scope: 'users:add').expiration_time = 2.weeks.ago.to_i }
          subject { Token.decode(token_string: token.to_s) }

          it 'is not a valid token' do
            expect(subject.error?).to be_truthy
          end

          it 'has an error that includes a `title`, `detail` & `status` key' do
            expect(subject.error).to have_key(:title).and have_key(:detail).and have_key(:status)
          end
        end
      end

      describe '#to_s' do
        it { expect(subject).to be_a(Token) }

        it 'is able to create an encoded token string' do
          expect(subject.to_s).to be_a(String)
        end
      end

      describe '#audience' do
        context 'when an audience is set' do
          before do
            subject.audience = 'Charlotte The Dog'
          end

          it 'has an audience claim after encoding & decoding' do
            decoded_token = Token.decode(token_string: subject.to_s)
            expect(decoded_token.audience).to eq('Charlotte The Dog')
          end
        end

        context 'when an audience is not set' do
          before do
            subject.audience = nil
          end

          it 'does not have an audience claim after encoding & decoding' do
            decoded_token = Token.decode(token_string: subject.to_s)
            expect(decoded_token.audience).to be_nil
          end
        end
      end

      describe '#subject' do
        context 'when a subject is set' do
          before do
            subject.subject = 'supercalifragilisticexpialidocious'
          end

          it 'has an subject claim after encoding & decoding' do
            decoded_token = Token.decode(token_string: subject.to_s)
            expect(decoded_token.subject).to eq('supercalifragilisticexpialidocious')
          end
        end

        context 'when a subject is not set' do
          before do
            subject.subject = nil
          end

          it 'does not have an subject claim after encoding & decoding' do
            decoded_token = Token.decode(token_string: subject.to_s)
            expect(decoded_token.subject).to be_nil
          end
        end
      end

      describe '#not_before' do
        let(:token) { Token.new(scope: 'users:add').not_before = 20.minutes.from_now.to_i }
        subject { Token.decode(token_string: token.to_s) }

        it 'is not a valid token yet' do
          expect(subject.error?).to be_truthy
        end
      end
    end
  end
end

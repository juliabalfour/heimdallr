module Heimdallr
  describe Application do
    subject do
      CreateApplication.new(
        name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
        scopes: 'users:create users:update tokens:delete universe:implode',
        algorithm: 'HS256'
      ).call
    end

    context 'database structure' do
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:scopes).of_type(:string) }
      it { should have_db_column(:key).of_type(:string) }
      it { should have_db_column(:ip).of_type(:inet) }
      it { should have_db_column(:encrypted_secret).of_type(:binary) }
      it { should have_db_column(:encrypted_secret_iv).of_type(:binary) }
      it { should have_db_column(:encrypted_certificate).of_type(:binary) }
      it { should have_db_column(:encrypted_certificate_iv).of_type(:binary) }
    end

    context 'model validations' do
      it { expect(subject).to validate_presence_of(:name) }
      it { expect(subject).to validate_presence_of(:scopes) }
    end

    describe '.cache_key' do
      it 'creates a cache key using two strings' do
        expect(Application.cache_key(id: 'a', key: 'b')).to eq('b:a')
      end
    end

    describe '#scopes=' do
      it 'converts a string into an array' do
        subject.scopes = 'users:all universe:create universe:delete'
        expect(subject.scopes).to be_a(Array)
      end
    end
  end
end

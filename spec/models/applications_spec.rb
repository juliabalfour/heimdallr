module Heimdallr
  describe Application do
    context 'database structure' do
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:scopes).of_type(:string) }
      it { should have_db_column(:ip).of_type(:inet) }
      it { should have_db_column(:encrypted_secret).of_type(:binary) }
      it { should have_db_column(:encrypted_secret_iv).of_type(:binary) }
      it { should have_db_column(:encrypted_certificate).of_type(:binary) }
      it { should have_db_column(:encrypted_certificate_iv).of_type(:binary) }
    end

    context 'model validations' do
      subject { FactoryGirl.build(:application) }
      it { expect(subject).to validate_presence_of(:name) }
      it { expect(subject).to validate_presence_of(:scopes) }
    end

    describe '#scopes=' do
      it 'converts a string into an array' do
        app = FactoryGirl.build(:application, scopes: 'users:all universe:create universe:delete')
        expect(app.scopes).to be_a(Array)
      end
    end
  end
end

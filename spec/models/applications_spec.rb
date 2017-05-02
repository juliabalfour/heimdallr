module Heimdallr
  describe Application do
    context 'db structure' do
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:scopes).of_type(:string) }
      it { should have_db_column(:ip).of_type(:inet) }
      it { should have_db_column(:encrypted_secret).of_type(:binary) }
      it { should have_db_column(:encrypted_secret_iv).of_type(:binary) }
      it { should have_db_column(:encrypted_certificate).of_type(:binary) }
      it { should have_db_column(:encrypted_certificate_iv).of_type(:binary) }
    end
  end
end

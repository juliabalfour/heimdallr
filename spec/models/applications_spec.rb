module Heimdallr
  describe Application do
    context 'db structure' do
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:secret).of_type(:string) }
      it { should have_db_column(:scopes).of_type(:string) }
      it { should have_db_column(:key).of_type(:uuid) }
      it { should have_db_column(:ip).of_type(:inet) }
      it { should have_db_column(:certificate).of_type(:text) }
      it { should have_db_column(:algorithm).of_type(:enum) }
    end
  end
end

module Heimdallr
  describe Token do
    context 'db structure' do
      it { should have_db_column(:token).of_type(:text) }
      it { should have_db_column(:created_at).of_type(:datetime) }
      it { should have_db_column(:expires_at).of_type(:datetime) }
      it { should have_db_column(:application_id).of_type(:uuid) }
    end
  end
end

module Heimdallr
  describe Token do
    context 'database structure' do
      it { should have_db_column(:application_id).of_type(:uuid) }
      it { should have_db_column(:scopes).of_type(:string) }
      it { should have_db_column(:data).of_type(:jsonb) }
      it { should have_db_column(:ip).of_type(:inet) }
      it { should have_db_column(:created_at).of_type(:datetime) }
      it { should have_db_column(:expires_at).of_type(:datetime) }
      it { should have_db_column(:revoked_at).of_type(:datetime) }
      it { should have_db_column(:not_before).of_type(:datetime) }
    end
  end
end

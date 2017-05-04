class CreateHeimdallrTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :heimdallr_tokens, id: :uuid do |t|
      t.references :application, type: :uuid, index: true

      t.string :scopes, null: false, default: '{}', array: true
      t.column :data, :jsonb, null: false, default: {}

      t.inet :ip, null: true
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at, null: true
      t.datetime :not_before, null: true
    end
  end
end

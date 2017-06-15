class AddHeimdallrTokens < ActiveRecord::Migration[5.1]
  def up
    change_table :tokens do |t|
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

  def down
    remove_column :tokens, :application_id
    remove_column :tokens, :scopes
    remove_column :tokens, :data
    remove_column :tokens, :ip
    remove_column :tokens, :created_at
    remove_column :tokens, :expires_at
    remove_column :tokens, :revoked_at
    remove_column :tokens, :not_before
  end
end

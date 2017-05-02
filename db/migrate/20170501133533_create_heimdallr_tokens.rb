class CreateHeimdallrTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :heimdallr_tokens, id: :uuid do |t|
      t.belongs_to :application, type: :uuid, index: true

      t.text     :token,       null: false
      t.datetime :created_at,  null: false
      t.datetime :expires_at,  null: false
    end
  end
end

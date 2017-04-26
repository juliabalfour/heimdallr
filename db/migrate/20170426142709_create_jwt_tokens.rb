class CreateJwtTokens < ActiveRecord::Migration[5.1]
  def change
    def change
      create_table :jwt_tokens, id: :uuid do |t|
        t.belongs_to :jwt_application, type: :uuid, index: true

        t.text      :token,       null: false
        t.datetime  :created_at,  null: false
      end
    end
  end
end

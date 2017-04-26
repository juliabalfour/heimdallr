class CreateJwtApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :jwt_applications, id: :uuid do |t|
      t.string  :name,    null: false
      t.uuid    :key,     null: false, default: 'uuid_generate_v4()'
      t.inet    :ip,      null: true
      t.string  :secret,  null: false
      t.string  :scopes,  null: false, default: ''
      t.timestamps
    end

    add_index :jwt_applications, :key, unique: true
  end
end

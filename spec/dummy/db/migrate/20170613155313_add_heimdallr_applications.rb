class AddHeimdallrApplications < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE TYPE jwt_algorithms AS ENUM ('HS256', 'HS384', 'HS512', 'RS256', 'RS384', 'RS512');
    SQL

    change_table :applications do |t|
      t.string :key,    null: false, index: :unique
      t.string :scopes, null: false, default: '{}', array: true

      t.column :algorithm, :jwt_algorithms, null: false, default: 'RS256'

      t.binary :encrypted_secret,         null: false
      t.binary :encrypted_secret_iv,      null: false
      t.binary :encrypted_certificate,    null: true
      t.binary :encrypted_certificate_iv, null: true

      t.inet :ip, null: true
    end
  end

  def down
    remove_column :applications, :key
    remove_column :applications, :scopes
    remove_column :applications, :algorithm
    remove_column :applications, :encrypted_secret
    remove_column :applications, :encrypted_secret_iv
    remove_column :applications, :encrypted_certificate
    remove_column :applications, :encrypted_certificate_iv
    remove_column :applications, :ip

    execute <<-SQL
      DROP TYPE jwt_algorithms;
    SQL
  end
end

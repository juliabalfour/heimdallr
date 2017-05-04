class CreateHeimdallrApplications < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE TYPE heimdallr_algorithms AS ENUM ('HS256', 'HS384', 'HS512', 'RS256', 'RS384', 'RS512');
    SQL

    create_table :heimdallr_applications, id: :uuid do |t|
      t.string :name,   null: false
      t.string :scopes, null: false, default: '{}', array: true

      t.column :algorithm, :heimdallr_algorithms, null: false, default: 'RS256'

      t.binary :encrypted_secret,         null: false
      t.binary :encrypted_secret_iv,      null: false
      t.binary :encrypted_certificate,    null: true
      t.binary :encrypted_certificate_iv, null: true

      t.inet :ip, null: true

      t.timestamps
    end
  end

  def down
    drop_table :heimdallr_applications

    execute <<-SQL
      DROP TYPE heimdallr_algorithms;
    SQL
  end
end

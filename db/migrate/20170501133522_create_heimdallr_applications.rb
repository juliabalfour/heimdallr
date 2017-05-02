class CreateHeimdallrApplications < ActiveRecord::Migration[5.1]
  def up

    execute <<-SQL
      CREATE TYPE heimdallr_algorithm AS ENUM ('HS256', 'HS384', 'HS512', 'RS256', 'RS384', 'RS512', 'ES256', 'ES384', 'ES512');
    SQL

    create_table :heimdallr_applications, id: :uuid do |t|
      t.string :name,   null: false
      t.string :secret, null: false
      t.string :scopes, null: false, default: '{}', array: true

      t.uuid :key, null: false, default: 'uuid_generate_v4()', index: :unique
      t.inet :ip,  null: true

      t.text :certificate, null: true

      t.column :algorithm, :heimdallr_algorithm, null: false, default: 'HS256'

      t.timestamps
    end
  end

  def down
    drop_table :heimdallr_applications

    execute <<-SQL
      DROP TYPE heimdallr_algorithm;
    SQL
  end
end

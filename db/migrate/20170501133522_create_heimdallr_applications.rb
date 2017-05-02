class CreateHeimdallrApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :heimdallr_applications, id: :uuid do |t|
      t.string :name,   null: false
      t.string :scopes, null: false, default: '{}', array: true

      t.binary :encrypted_secret,         null: false
      t.binary :encrypted_secret_iv,      null: false
      t.binary :encrypted_certificate,    null: true
      t.binary :encrypted_certificate_iv, null: true

      t.inet :ip, null: true

      t.timestamps
    end
  end
end

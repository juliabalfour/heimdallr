class CreateApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :applications, id: :uuid do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end

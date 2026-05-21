class CreateStates < ActiveRecord::Migration[7.2]
  def change
    create_table :states do |t|
      t.string :name
      t.string :abbreviation
      t.string :department_name
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.string :api_type
      t.string :api_version
      t.string :data_format
      t.string :auth_method
      t.text :protocol_notes

      t.timestamps
    end

    add_index :states, :abbreviation, unique: true
  end
end

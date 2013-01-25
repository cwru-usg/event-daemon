class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.integer :collegiatelink_id
      t.integer :organization_id

      t.datetime :starts
      t.datetime :ends

      t.timestamps
    end
  end
end

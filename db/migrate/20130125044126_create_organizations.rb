class CreateOrganizations < ActiveRecord::Migration
  def up
    create_table :organizations do |t|
      t.integer :collegiatelink_id
      t.string :name
      t.string :short_name
      t.string :status

      t.timestamps
    end
  end

  def down
    drop_table :organizations
  end
end

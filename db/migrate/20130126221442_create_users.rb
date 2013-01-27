class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.integer :collegiatelink_id
      t.string :firstname
      t.string :lastname
      t.string :campusemail
      t.boolean :is_finance_team

      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end

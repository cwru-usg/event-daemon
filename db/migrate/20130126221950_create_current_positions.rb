class CreateCurrentPositions < ActiveRecord::Migration
  def up
    create_table :current_positions do |t|
      t.integer :organization_id
      t.integer :user_id
    end
  end

  def down
    drop_table :current_positions
  end
end

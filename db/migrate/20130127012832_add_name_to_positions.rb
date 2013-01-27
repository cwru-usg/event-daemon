class AddNameToPositions < ActiveRecord::Migration
  def change
    change_table :current_positions do |t|
      t.string :name
    end
  end
end

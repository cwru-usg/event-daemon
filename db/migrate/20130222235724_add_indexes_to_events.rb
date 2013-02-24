class AddIndexesToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.index [:starts, :ends]
      t.index :state
      t.index :collegiatelink_id
    end
  end
end

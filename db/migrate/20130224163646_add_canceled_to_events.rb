class AddCanceledToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.boolean :canceled, :default => :false
    end
  end
end

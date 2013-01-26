class AddStateToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :state
    end
  end
end

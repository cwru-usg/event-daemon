class AddErrorToEvent < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :error
    end
  end
end

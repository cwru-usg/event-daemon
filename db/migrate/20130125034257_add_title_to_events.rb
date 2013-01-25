class AddTitleToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :title
    end
  end
end

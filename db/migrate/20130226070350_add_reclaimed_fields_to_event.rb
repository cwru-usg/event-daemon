class AddReclaimedFieldsToEvent < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.decimal :reclaimed_amount
      t.datetime :reclaimed_at
    end
  end
end

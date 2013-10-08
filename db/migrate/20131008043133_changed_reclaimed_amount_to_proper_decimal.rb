class ChangedReclaimedAmountToProperDecimal < ActiveRecord::Migration
  def up
    change_column :events, :reclaimed_amount, :decimal, :precision => 10, :scale => 2
  end

  def down
    change_column :events, :reclaimed_amount, :decimal, :precision => 10, :scale => 2
  end
end

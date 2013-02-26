class RenameCancelledToCanceled < ActiveRecord::Migration
  def up
    Event.where(:state => 'cancelled').each do |e|
      e.update_attribute(:state, 'canceled')
    end
  end

  def down
    Event.where(:state => 'canceled').each do |e|
      e.update_attribute(:state, 'cancelled')
    end
  end
end

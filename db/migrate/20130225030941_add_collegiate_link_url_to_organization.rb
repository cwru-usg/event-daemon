class AddCollegiateLinkUrlToOrganization < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.string :collegiatelink_url
    end
  end
end

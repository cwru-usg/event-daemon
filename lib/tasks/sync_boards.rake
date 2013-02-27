namespace :usg do
  desc "Synchronize all executive boards"
  task :sync_exec => :sync_orgs do
    Organization.all.each do |o|
      o.sync_executive_board!
      o.touch
    end
  end

  desc "Synchronize the list of organizations"
  task :sync_orgs => :environment do
    Organization.sync_from_collegiatelink!
  end
end

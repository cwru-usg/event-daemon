class AddDefaultFinanceTeamMembers < ActiveRecord::Migration
  def up
    User.where(:username => 'ted27').first_or_create(:firstname => 'Thomas', :lastname => 'Dooner', :campusemail => 'ted27@case.edu', :is_finance_team => true)
    User.where(:username => 'cpw23').first_or_create(:firstname => 'Colin', :lastname => 'Williams', :campusemail => 'cpw23@case.edu', :is_finance_team => true)
    User.where(:username => 'ler52').first_or_create(:firstname => 'Levi', :lastname => 'Ridgeway', :campusemail => 'ler52@case.edu', :is_finance_team => true)
    User.where(:username => 'lap80').first_or_create(:firstname => 'Laura', :lastname => 'Payne', :campusemail => 'lap80@case.edu', :is_finance_team => true)
  end

  def down
    # You can't delete the finance team members!!!
  end
end

require 'spec_helper'

describe Organization do
  describe '#sync_executive_board!' do
    let!(:organization) { FactoryGirl.create(:organization) }
    let(:position) { FactoryGirl.create(:current_position,
                       :organization => organization,
                       :name => 'President') }
    let(:normal_guy) { FactoryGirl.create(:current_position,
                       :organization => organization) }
    let(:another_exec) { FactoryGirl.create(:current_position,
                       :organization => organization,
                       :name => 'President') }

    context 'when the position is inactive' do
      before do
        COLLEGIATELINK.stubs(:roster => [ position.user ])
        position.user.stubs(:active_positions => [ ])
      end

      it "doesn't sync the position" do
        organization.sync_executive_board!

        organization.exec_positions.should_not include(position)
      end
    end

    context 'when the executive board is empty' do
      before do
        COLLEGIATELINK.stubs(:roster => [ position.user ])
        position.user.stubs(:active_positions => [ position ])
      end

      it 'creates positions for the members of the executive board' do
        organization.sync_executive_board!

        organization.exec_members.first.username.should == position.user.username
      end

      it 'uses existing User objects if they exist' do
        organization.sync_executive_board!

        organization.exec_positions.first.user_id.should == position.user.id
      end

      context 'when there are multiple users' do
        before do
          COLLEGIATELINK.stubs(:roster => [ position.user, normal_guy.user, another_exec.user ])
          position.user.stubs(:active_positions => [ position ])
          normal_guy.user.stubs(:active_positions => [ normal_guy ])
          another_exec.user.stubs(:active_positions => [ another_exec ])
        end

        it 'syncs only members with executive titles' do
          organization.sync_executive_board!

          organization.exec_positions.should_not include(normal_guy)
        end

        it 'syncs all executive officers' do
          organization.sync_executive_board!

          organization.exec_members.should include(position.user)
          organization.exec_members.should include(another_exec.user)
        end
      end

      it 'uniqifies the list of members' do
        COLLEGIATELINK.stubs(:roster => [ position.user, position.user ])
        organization.sync_executive_board!

        organization.exec_members.length.should == 1
      end
    end

    context 'when the executive board already exists' do
      before do
        COLLEGIATELINK.stubs(:roster => [ position.user ])
        position.user.stubs(:active_positions => [ position ])

        organization.sync_executive_board!
      end

      context 'when a member is added' do
        before do
          COLLEGIATELINK.stubs(:roster => [ position.user, another_exec.user ])
          position.user.stubs(:active_positions => [ position ])
          another_exec.user.stubs(:active_positions => [ another_exec ])
        end

        it 'adds them to the executive board' do
          organization.exec_members.should include(another_exec.user)
        end
      end

      context 'when a member is removed' do
        before do
          COLLEGIATELINK.stubs(:roster => [])
        end

        it 'removes them from the executive board' do
          organization.sync_executive_board!

          organization.exec_members.should be_empty
        end
      end
    end
  end
end

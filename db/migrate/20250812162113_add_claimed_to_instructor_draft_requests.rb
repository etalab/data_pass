class AddClaimedToInstructorDraftRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :instructor_draft_requests, :claimed, :boolean, default: false, null: false
  end
end

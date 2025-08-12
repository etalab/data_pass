class AddClaimedToAuthorizationRequestInstructorDrafts < ActiveRecord::Migration[8.0]
  def change
    add_column :authorization_request_instructor_drafts, :claimed, :boolean, default: false, null: false
  end
end

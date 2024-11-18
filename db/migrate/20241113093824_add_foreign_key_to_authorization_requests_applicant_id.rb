class AddForeignKeyToAuthorizationRequestsApplicantId < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :authorization_requests, :users, column: :applicant_id
  end
end

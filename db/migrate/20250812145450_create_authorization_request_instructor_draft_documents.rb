class CreateAuthorizationRequestInstructorDraftDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :authorization_request_instructor_draft_documents do |t|
      t.string :identifier, null: false
      t.references :authorization_request_instructor_draft, null: false, foreign_key: true

      t.timestamps
    end
  end
end

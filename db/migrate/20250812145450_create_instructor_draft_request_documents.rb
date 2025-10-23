class CreateInstructorDraftRequestDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :instructor_draft_request_documents do |t|
      t.string :identifier, null: false
      t.references :instructor_draft_request, null: false, foreign_key: true

      t.timestamps
    end

    add_column :instructor_draft_requests, :form_uid, :string, null: false
  end
end

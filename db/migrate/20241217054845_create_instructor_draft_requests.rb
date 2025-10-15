class CreateInstructorDraftRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :instructor_draft_requests do |t|
      t.string :authorization_request_class, null: false
      t.hstore :data, null: false
      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      t.integer :applicant_id
      t.integer :organization_id
      t.references :instructor, foreign_key: { to_table: :users }, null: false
      t.text :comment

      t.timestamps
    end

    add_foreign_key :instructor_draft_requests, :users, column: :applicant_id
    add_foreign_key :instructor_draft_requests, :organizations
  end
end

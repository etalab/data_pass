class CreateAuthorizationRequestInstructorDrafts < ActiveRecord::Migration[8.0]
  def change
    create_table :authorization_request_instructor_drafts do |t|
      t.string :authorization_request_class, null: false
      t.hstore :data, null: false
      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      t.integer :applicant_id
      t.integer :organization_id
      t.references :instructor, foreign_key: { to_table: :users }, null: false
      t.text :comment

      t.timestamps
    end

    add_foreign_key :authorization_request_instructor_drafts, :users, column: :applicant_id
    add_foreign_key :authorization_request_instructor_drafts, :organizations
  end
end

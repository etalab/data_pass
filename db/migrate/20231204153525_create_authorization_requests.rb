class CreateAuthorizationRequests < ActiveRecord::Migration[7.1]
  def change
    enable_extension "hstore"

    create_table :authorization_requests do |t|
      t.string :type, null: false
      t.string :state, null: false, default: 'draft'
      t.references :organization, null: false, index: true
      t.integer :applicant_id, null: false, index: true
      t.boolean :terms_of_service_accepted, null: false, default: false
      t.boolean :data_protection_officer_informed, null: false, default: false
      t.hstore :data, null: false, default: {}
      t.datetime :last_validated_at

      t.timestamps
    end
  end
end

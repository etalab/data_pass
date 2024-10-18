FactoryBot.define do
  factory :active_storage_attachment, class: 'ActiveStorage::Attachment' do
    name { 'file' }
    record_type { 'AuthorizationDocument' }
    record_id { create(:authorization_document).id }
    blob { association :active_storage_blob }
  end
end

FactoryBot.define do
  factory :active_storage_blob, class: 'ActiveStorage::Blob' do
    transient do
      filename { 'dummy.pdf' }
      content { 'dummy_content' }
      io { StringIO.new(content) }
    end

    initialize_with do
      ActiveStorage::Blob.build_after_unfurling(io:, filename:)
    end

    after(:create) { |blob, context| blob.upload_without_unfurling(context.io) }
  end
end

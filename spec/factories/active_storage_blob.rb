FactoryBot.define do
  factory :active_storage_blob, class: 'ActiveStorage::Blob' do
    # key { SecureRandom.uuid }
    # filename { 'dummy.pdf' }
    # content_type { 'file/pdf' }
    # byte_size { 1024 }
    # checksum { Digest::MD5.base64digest('dummy_content') }
    # service_name { 'local' }

    # after(:build) do |blob|
    #   file_path = Rails.root.join('spec/fixtures/dummy.pdf')
    #   io = File.open(file_path)
    #   blob.upload(io)
    #   io.close
    # end

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

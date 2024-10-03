module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :malware_scan, dependent: :destroy
  end
end

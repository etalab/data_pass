module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :malware_scan, dependent: :destroy

    delegate :safe?, :unsafe?, to: :malware_scan, allow_nil: true
  end
end

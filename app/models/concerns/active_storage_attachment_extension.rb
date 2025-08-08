module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :malware_scan, dependent: :destroy

    delegate :safe?, :unsafe?, to: :malware_scan, allow_nil: true

    before_destroy :ensure_malware_scan_cleanup
  end

  private

  def ensure_malware_scan_cleanup
    return if malware_scan.blank?

    begin
      malware_scan.destroy!
    rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey => e
      Rails.logger.warn "Failed to destroy malware_scan #{malware_scan.id} for attachment #{id}: #{e.message}"
      malware_scan.delete
    end
  end
end

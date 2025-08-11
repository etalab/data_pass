Rails.configuration.to_prepare do
  ActiveStorage::Attachment.class_eval do
    has_one :malware_scan, dependent: :destroy

    delegate :safe?, :unsafe?, to: :malware_scan, allow_nil: true

    alias_method :orginal_purge, :purge
    alias_method :orginal_purge_later, :purge_later

    def purge
      malware_scan&.destroy
      orginal_purge
    end

    def purge_later
      malware_scan&.destroy
      orginal_purge_later
    end
  end
end

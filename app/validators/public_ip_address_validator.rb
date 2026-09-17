class PublicIpAddressValidator < ActiveModel::EachValidator
  SEPARATORS = /[,;\n]/

  def validate_each(record, attribute, value)
    return if value.blank?

    entries = value.split(SEPARATORS).map(&:strip).compact_blank

    return if entries.any? && entries.all? { |entry| public_ip_address?(entry) }

    record.errors.add(attribute, :invalid_public_ip_address)
  end

  private

  def public_ip_address?(entry)
    address = IPAddr.new(entry)

    !address.private? &&
      !address.loopback? &&
      !address.link_local? &&
      address.prefix.positive?
  rescue IPAddr::Error
    false
  end
end

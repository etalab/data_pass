class ReopeningChangesChecker
  def initialize(authorization_request)
    @authorization_request = authorization_request
    @latest_approval = authorization_request.latest_authorization_of_class(authorization_request.class_name)
  end

  def changed?
    data_changed? || documents_changed?
  end

  private

  attr_reader :authorization_request, :latest_approval

  def data_changed?
    previous_data = Hash(latest_approval&.data)
    current_data = Hash(authorization_request.data)

    compared_keys(previous_data, current_data).any? do |key|
      previous_data[key].presence != current_data[key].presence
    end
  end

  def compared_keys(previous_data, current_data)
    previous_data.keys | (current_data.keys & authorization_request.class.extra_attributes.map(&:to_s))
  end

  def documents_changed?
    authorization_request.class.documents.any? do |document|
      current_blob_ids(document.name) != approved_blob_ids(document.name)
    end
  end

  def current_blob_ids(document_name)
    ActiveStorage::Attachment.where(record: authorization_request, name: document_name).pluck(:blob_id).sort
  end

  def approved_blob_ids(document_name)
    return [] if latest_approval.nil?

    ActiveStorage::Attachment
      .where(record: latest_approval.documents.where(identifier: document_name), name: 'files')
      .pluck(:blob_id)
      .sort
  end
end

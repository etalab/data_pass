class API::V1::AuthorizationRequestEventSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :created_at,
    :entity

  has_one :user, serializer: WebhookUserSerializer

  def entity
    {
      type: object.entity_type,
      id: object.entity_id,
      diff:,
      reason:,
    }.compact
  end

  private

  def diff
    object.entity.respond_to?(:diff) ? object.entity.diff : nil
  end

  def reason
    object.entity.respond_to?(:reason) ? object.entity.reason : nil
  end
end

class API::V1::AuthorizationRequestSerializer < ActiveModel::Serializer
  attributes :id,
    :public_id,
    :type,
    :state,
    :form_uid,
    :data,
    :created_at,
    :last_submitted_at,
    :last_validated_at,
    :reopening,
    :reopened_at

  has_many :authorizations, serializer: API::V1::AuthorizationSerializer, key: :habilitations
  has_one :organization, serializer: API::V1::OrganizationSerializer, key: :organisation
  has_many :events, serializer: API::V1::AuthorizationRequestEventSerializer, key: :events

  def reopening
    object.reopening?
  end
end

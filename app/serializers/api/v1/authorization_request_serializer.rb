class API::V1::AuthorizationRequestSerializer < ActiveModel::Serializer
  attributes :id,
    :public_id,
    :type,
    :state,
    :form_uid,
    :data,
    :created_at,
    :updated_at,
    :last_submitted_at,
    :last_validated_at,
    :reopening,
    :reopened_at

  has_many :authorizations, serializer: API::V1::AuthorizationSerializer, key: :habilitations
  has_one :organization, serializer: API::V1::OrganizationSerializer, key: :organisation
end

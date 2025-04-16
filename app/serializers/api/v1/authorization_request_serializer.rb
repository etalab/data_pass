class API::V1::AuthorizationRequestSerializer < ActiveModel::Serializer
  attributes :id,
    :public_id,
    :type,
    :state,
    :form_uid,
    :data,
    :created_at,
    :last_submitted_at,
    :last_validated_at

  has_many :authorizations, serializer: API::V1::AuthorizationSerializer, key: :habilitations
end

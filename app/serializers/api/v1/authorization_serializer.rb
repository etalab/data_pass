class API::V1::AuthorizationSerializer < ActiveModel::Serializer
  attributes :id,
    :slug,
    :form_uid,
    :revoked,
    :state,
    :created_at,
    :data
end

class API::V1::AuthorizationSerializer < ActiveModel::Serializer
  attributes :id,
    :slug,
    :revoked,
    :state,
    :created_at,
    :data,
    :authorization_request_class
end

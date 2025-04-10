class API::V1::AuthorizationRequestEventSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :created_at
end

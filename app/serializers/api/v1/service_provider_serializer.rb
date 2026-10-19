class API::V1::ServiceProviderSerializer < ActiveModel::Serializer
  attributes :id,
    :siret,
    :type
end

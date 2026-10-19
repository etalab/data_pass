class API::V1::OrganizationSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :siret,
    :insee_payload
end

class API::V1::OrganizationSerializer < ActiveModel::Serializer
  attributes :id,
    :siret,
    :insee_payload
end

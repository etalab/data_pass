class API::V1::OrganizationSerializer < ActiveModel::Serializer
  attributes :id,
    :siret,
    :raison_sociale,
    :insee_payload
end

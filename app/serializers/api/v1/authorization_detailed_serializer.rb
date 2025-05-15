class API::V1::AuthorizationDetailedSerializer < API::V1::AuthorizationSerializer
  attribute :request_id, key: :demande_id

  has_one :organization, serializer: API::V1::OrganizationSerializer, key: :organisation
end

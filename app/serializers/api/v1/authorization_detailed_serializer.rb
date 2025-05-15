class API::V1::AuthorizationDetailedSerializer < API::V1::AuthorizationSerializer
  has_one :organization, serializer: API::V1::OrganizationSerializer, key: :organisation
end

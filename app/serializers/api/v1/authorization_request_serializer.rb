class API::V1::AuthorizationRequestSerializer < ActiveModel::Serializer
  attributes :id,
    :public_id,
    :definition_id,
    :type,
    :state,
    :form_uid,
    :data,
    :created_at,
    :last_submitted_at,
    :last_validated_at,
    :reopening,
    :reopened_at

  has_many :authorizations, serializer: API::V1::AuthorizationSerializer, key: :habilitations
  has_one :organization, serializer: API::V1::OrganizationSerializer, key: :organisation
  has_one :applicant, serializer: API::V1::UserSerializer, key: :applicant
  has_many :events_without_bulk_update, serializer: API::V1::AuthorizationRequestEventSerializer, key: :events

  def reopening
    object.reopening?
  end

  def definition_id
    object.definition.id
  end

  # Expose the geographic entity (inferred from the org, not stored) alongside
  # the stored data so downstream consumers (relais) can resolve the perimeter
  # without access to the organisation's INSEE payload.
  def data
    return object.data unless object.respond_to?(:geographic_perimeter_declaration)

    declaration = object.geographic_perimeter_declaration
    return object.data if declaration.nil?

    object.data.merge('entity_type' => declaration[:type], 'code_insee_entity' => declaration[:code])
  end
end

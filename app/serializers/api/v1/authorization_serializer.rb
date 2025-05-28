class API::V1::AuthorizationSerializer < ActiveModel::Serializer
  attributes :id,
    :slug,
    :revoked,
    :state,
    :created_at,
    :data,
    :authorization_request_class,
    :definition_id

  def definition_id
    AuthorizationDefinition.find_by(authorization_request_class: object.authorization_request_class).id
  end
end

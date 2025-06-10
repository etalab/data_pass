class API::V1::AuthorizationDefinitionSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :multi_stage?,
    :authorization_request_class,
    :scopes

  def name
    object.name_with_stage
  end

  def authorization_request_class
    object.authorization_request_class.to_s
  end

  def scopes
    ActiveModel::Serializer::CollectionSerializer.new(
      object.scopes,
      serializer: API::V1::ScopeSerializer
    )
  end
end

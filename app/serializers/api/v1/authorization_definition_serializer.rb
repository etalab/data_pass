class API::V1::AuthorizationDefinitionSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :multi_stage?,
    :authorization_request_class,
    :data_attributes,
    :scopes

  def name
    object.name_with_stage
  end

  def authorization_request_class
    object.authorization_request_class.to_s
  end

  def data_attributes
    attributes_list = object.authorization_request_class.extra_attributes
    attributes_list.push(:scopes) if object.scopes.any?
    attributes_list
  end

  def scopes
    ActiveModel::Serializer::CollectionSerializer.new(
      object.scopes,
      serializer: API::V1::ScopeSerializer
    )
  end
end

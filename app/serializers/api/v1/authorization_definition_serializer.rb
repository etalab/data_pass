class API::V1::AuthorizationDefinitionSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :multi_stage?,
    :authorization_request_class,
    :data,
    :scopes

  def name
    object.name_with_stage
  end

  def authorization_request_class
    object.authorization_request_class.to_s
  end

  def data
    data_attributes = object.authorization_request_class.extra_attributes
    data_attributes.push(:scopes) if object.scopes.any?
    data_attributes
  end

  def scopes
    object.scopes.map(&:value)
  end
end

class API::V1::AuthorizationDefinitionSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :name_with_stage,
    :multi_stage?,
    :authorization_request_class

  def authorization_request_class
    object.authorization_request_class.to_s
  end
end

class API::V1::AuthorizationDefinitionSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :provider,
    :description,
    :link,
    :access_link,
    :cgu_link,
    :support_email,
    :kind,
    :scopes,
    :blocks,
    :features,
    :stage,
    :name_with_stage,
    :multi_stage?,
    :authorization_request_class

  def authorization_request_class
    object.authorization_request_class.to_s
  end
end

class API::V1::AuthorizationRequestFormSerializer < ActiveModel::Serializer
  attributes :uid,
    :name,
    :description,
    :use_case,
    :definition_id,
    :authorization_request_class,
    :data

  def authorization_request_class
    object.authorization_request_class.to_s
  end

  delegate :multiple_steps?, to: :object

  def definition_id
    AuthorizationDefinition.find_by(authorization_request_class: object.authorization_request_class.to_s)&.id
  end
end

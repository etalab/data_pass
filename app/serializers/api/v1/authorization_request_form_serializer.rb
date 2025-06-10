class API::V1::AuthorizationRequestFormSerializer < ActiveModel::Serializer
  delegate :multiple_steps?, to: :object

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

  def definition_id
    object.authorization_definition.id
  end
end

class API::V1::AuthorizationRequestFormSerializer < ActiveModel::Serializer
  attributes :uid,
    :name,
    :description,
    :use_case,
    :authorization_request_class,
    :prefilled?

  def authorization_request_class
    object.authorization_request_class.to_s
  end

  delegate :multiple_steps?, to: :object

  delegate :single_page?, to: :object

  delegate :prefilled?, to: :object
end

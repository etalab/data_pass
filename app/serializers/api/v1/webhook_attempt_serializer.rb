class API::V1::WebhookAttemptSerializer < ActiveModel::Serializer
  attributes :id,
    :event,
    :status_code,
    :response_body,
    :created_at,
    :authorization_request_id

  def event
    object.event_name
  end

  def authorization_request_id
    object.authorization_request.id
  end
end

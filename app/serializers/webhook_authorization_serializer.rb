class WebhookAuthorizationSerializer < ApplicationSerializer
  attributes :id,
    :slug,
    :revoked,
    :state,
    :created_at,
    :data,
    :authorization_request_class,
    :definition_id

  def definition_id
    object.definition.id
  end
end

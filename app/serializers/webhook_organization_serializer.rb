class WebhookOrganizationSerializer < ApplicationSerializer
  attributes :id,
    :name,
    :insee_payload,
    :siret
end

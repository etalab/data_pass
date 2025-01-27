class WebhookAuthorizationRequestSerializer < ApplicationSerializer
  attributes :id,
    :public_id,
    :state,
    :form_uid,
    :data

  has_one :organization, serializer: WebhookOrganizationSerializer
  has_one :applicant, serializer: WebhookUserSerializer
  has_one :service_provider, serializer: WebhookServiceProviderSerializer

  def data
    object.data.keys.index_with { |key|
      begin
        object.public_send(key)
      rescue NoMethodError
        nil
      end
    }.compact.symbolize_keys
  end
end

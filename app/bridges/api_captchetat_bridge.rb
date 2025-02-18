class APICaptchEtatBridge < ApplicationBridge
  def on_approve
    payload = PISTEAPIClient.new.create_subscription(authorization_request)

    authorization_request.update!(external_provider_id: extract_id_from_prd_link(payload))
  end

  private

  def extract_id_from_prd_link(payload)
    payload['piste_app_prd_link'].split('/').last
  end
end

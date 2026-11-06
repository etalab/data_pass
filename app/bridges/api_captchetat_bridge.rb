class APICaptchEtatBridge < ApplicationBridge
  MAX_ATTEMPTS = 3
  WAIT_BETWEEN_ATTEMPTS = 6.hours

  discard_on StandardError

  retry_on Faraday::TooManyRequestsError,
    Faraday::ConnectionFailed,
    wait: WAIT_BETWEEN_ATTEMPTS,
    attempts: MAX_ATTEMPTS

  def on_approve
    payload = PISTEAPIClient.create_subscription(authorization_request)

    authorization_request.update!(external_provider_id: extract_id_from_prd_link(payload))
  end

  private

  def track_error_now?
    true
  end

  def extract_id_from_prd_link(payload)
    payload['piste_app_prd_link'].split('/').last
  end
end

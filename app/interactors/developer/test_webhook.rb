class Developer::TestWebhook < ApplicationInteractor
  def call
    result = make_test_request

    assign_success_result(result)
  rescue Faraday::Error => e
    assign_error_result(e)
  end

  private

  def make_test_request
    test_payload = build_test_payload
    http_service = WebhookHttpService.new(context.webhook.url, context.webhook.secret)
    http_service.call(test_payload)
  end

  def build_test_payload
    {
      test: true,
      timestamp: Time.current.iso8601
    }
  end

  def assign_success_result(result)
    context.webhook_test = {
      success: result[:status_code].in?([200, 201, 204]),
      status_code: result[:status_code],
      response_body: result[:response_body]
    }
  end

  def assign_error_result(error)
    context.webhook_test = {
      success: false,
      status_code: nil,
      response_body: error.message
    }
  end
end

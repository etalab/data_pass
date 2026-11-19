module OmniAuth
  module FailureReporter
    module_function

    def call(env)
      report(env)
      keep_return_to_as_origin(env)

      endpoint = OmniAuth::FailureEndpoint.new(env)
      Rails.env.development? ? endpoint.raise_out! : endpoint.redirect_to_failure
    end

    def report(env)
      details = failure_details(env)

      Rails.logger.warn("[OmniAuth] authentication failure #{details.to_json}")
      Sentry.capture_message('OmniAuth authentication failure', level: :warning, extra: details)
    end

    def keep_return_to_as_origin(env)
      return_to = env.dig('omniauth.params', 'return_to')

      env['omniauth.origin'] = return_to if return_to.present?
    end

    def failure_details(env)
      {
        strategy: env['omniauth.error.strategy']&.name,
        type: env['omniauth.error.type'],
        error: env['omniauth.error']&.message
      }
    end
  end
end

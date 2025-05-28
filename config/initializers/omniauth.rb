require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class MonComptePro < OmniAuth::Strategies::OAuth2
      option :name, :mon_compte_pro

      option :client_options, {
        site: Rails.application.credentials.mon_compte_pro_url,
        authorize_url: '/oauth/authorize',
        callback_path: '/auth/mon_compte_pro/callback',
        auth_scheme: :basic_auth,
        ssl: {
          verify: !Rails.env.development?
        }
      }

      option :scope, 'openid email profile phone organization'

      uid { raw_info['sub'] }
      info { raw_info }

      def callback_url
        full_host + callback_path
      end

      private

      def raw_info
        @raw_info ||= access_token.get('/oauth/userinfo').parsed
      end
    end
  end
end

setup_proc = lambda do |env|
  env['omniauth.strategy'].options[:client_id] = Rails.application.credentials.mon_compte_pro_client_id
  env['omniauth.strategy'].options[:client_secret] = Rails.application.credentials.mon_compte_pro_client_secret

  prompt_param = Rack::Utils.parse_nested_query(env['QUERY_STRING'])['prompt']
  return_to = Rack::Utils.parse_nested_query(env['QUERY_STRING'])['return_to']

  if %w[select_organization update_userinfo].include?(prompt_param)
    env['omniauth.strategy'].options[:authorize_params] = {
      prompt: prompt_param,
    }
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :mon_compte_pro, setup: setup_proc

  provider(
    :proconnect,
    {
      client_id: Rails.application.credentials.proconnect_client_id,
      client_secret: Rails.application.credentials.proconnect_client_secret,
      proconnect_domain: Rails.application.credentials.proconnect_url,
      # proconnect_domain: %w[development test].include?(Rails.env) ? 'https://fca.integ01.dev-agentconnect.fr/api/v2' : 'https://auth.agentconnect.gouv.fr/api/v2',
      redirect_uri: URI('http://localhost:3000/auth/proconnect/callback').to_s,
      # post_logout_redirect_uri: 'http://localhost:3000',
      scope: 'openid given_name usual_name email uid siret organizational_unit phone idp_id',
    }
  )
end

OmniAuth.config.test_mode = Rails.env.test?
OmniAuth.config.logger = Rails.logger

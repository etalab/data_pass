require 'omniauth-oauth2'
require 'omniauth/proconnect'

module ProConnectConfig
  module_function

  def host
    case Rails.env
    when 'development', 'test'
      'http://localhost:3000'
    when 'sandbox', 'staging'
      "https://#{Rails.env}.datapass.api.gouv.fr"
    when 'production'
      'https://datapass.api.gouv.fr'
    end
  end

  def client_id
    Rails.application.credentials.proconnect_client_id
  end

  def client_secret
    Rails.application.credentials.proconnect_client_secret
  end

  def domain
    Rails.application.credentials.proconnect_url
  end

  def redirect_uri
    "#{host}/auth/proconnect/callback"
  end

  def scope
    'openid given_name usual_name email uid idp_id siret phone'
  end
end

module OmniAuth
  module Strategies
    class Proconnect
      MFA_ACR_VALUES = [
        'eidas2',
        'eidas3',
        'https://proconnect.gouv.fr/assurance/self-asserted-2fa',
        'https://proconnect.gouv.fr/assurance/consistency-checked-2fa'
      ].freeze

      def self.authorization_uri_with_mfa(session:, login_hint:)
        new_state = SecureRandom.hex(16)
        new_nonce = SecureRandom.hex(16)
        session['omniauth.state'] = new_state
        session['omniauth.nonce'] = new_nonce

        params = {
          response_type: 'code',
          client_id: ProConnectConfig.client_id,
          redirect_uri: ProConnectConfig.redirect_uri,
          scope: ProConnectConfig.scope,
          state: new_state,
          nonce: new_nonce,
          login_hint: login_hint,
          claims: mfa_claims.to_json
        }

        URI(authorization_endpoint).tap { |uri|
          uri.query = URI.encode_www_form(params)
        }.to_s
      end

      def self.mfa_claims
        {
          id_token: {
            amr: { essential: true },
            acr: { essential: true, values: MFA_ACR_VALUES }
          }
        }
      end

      def self.authorization_endpoint
        @authorization_endpoint ||= discovered_configuration['authorization_endpoint']
      end

      def self.discovered_configuration
        @discovered_configuration ||= Faraday.new(url: ProConnectConfig.domain) { |c|
          c.response :json
        }.get('.well-known/openid-configuration').body
      end

      private

      def authorization_uri
        URI(discovered_configuration['authorization_endpoint']).tap do |endpoint|
          endpoint.query = URI.encode_www_form(
            response_type: 'code',
            client_id: options[:client_id],
            redirect_uri: options[:redirect_uri],
            scope: options[:scope],
            state: store_new_state!,
            nonce: store_new_nonce!,
            claims: { id_token: { amr: { essential: true } } }.to_json
          )
        end
      end
    end
  end
end

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
      client_id: ProConnectConfig.client_id,
      client_secret: ProConnectConfig.client_secret,
      proconnect_domain: ProConnectConfig.domain,
      redirect_uri: ProConnectConfig.redirect_uri,
      post_logout_redirect_uri: ProConnectConfig.host,
      scope: ProConnectConfig.scope
    }
  )
end

OmniAuth.config.test_mode = Rails.env.test?
OmniAuth.config.logger = Rails.logger

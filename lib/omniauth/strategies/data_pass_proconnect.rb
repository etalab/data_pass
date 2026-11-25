require 'omniauth/proconnect'

module OmniAuth
  module Strategies
    class DataPassProconnect < Proconnect
      MFA_ACR_VALUES = %w[
        eidas0-mfa
        eidas1-mfa
        eidas2
        eidas3
      ].freeze

      ID_TOKEN_SIGNING_ALGORITHMS = %w[RS256 HS256].freeze
      ID_TOKEN_EXPIRY_LEEWAY = 10.seconds

      option :name, 'proconnect'

      class CallbackError < Error
        attr_reader :key

        def initialize(key, message = key.to_s)
          @key = key
          super(message)
        end
      end

      extra do
        {
          raw_info: @userinfo,
          acr: id_token_claims['acr'],
          amr: id_token_claims['amr']
        }
      end

      def callback_phase
        failure = callback_failure

        failure ? fail!(failure.key, failure) : omniauth_callback_phase
      end

      private

      def omniauth_callback_phase
        OmniAuth::Strategy.instance_method(:callback_phase).bind_call(self)
      end

      def callback_failure
        return provider_error if request.params['error'].present?
        return CallbackError.new(:csrf_detected) unless valid_state?

        fetch_verified_identity!
        nil
      rescue Faraday::Error => e
        CallbackError.new(:token_exchange_failed, e.message)
      rescue CallbackError => e
        e
      end

      def provider_error
        CallbackError.new(:proconnect_error, request.params.values_at('error', 'error_description').compact.join(': '))
      end

      def valid_state?
        expected_state = current_state.to_s

        expected_state.present? && ActiveSupport::SecurityUtils.secure_compare(request.params['state'].to_s, expected_state)
      end

      def fetch_verified_identity!
        store_tokens!(exchange_authorization_code!(request.params['code']))
        @id_token_claims = verified_id_token_claims
        @userinfo = JSON::JWT.decode(get_userinfo!.body, :skip_verification)

        raise CallbackError.new(:invalid_id_token, 'userinfo sub differs from id_token sub') unless @userinfo['sub'] == @id_token_claims['sub']

        remember_id_token_for_logout! if keeps_id_token_for_logout?
      end

      def keeps_id_token_for_logout?
        true
      end

      def remember_id_token_for_logout!
        session[id_token_session_key] = raw_id_token
      end

      def verified_id_token_claims
        claims = decode_id_token
        invalid_claim = invalid_id_token_claim(claims)
        raise CallbackError.new(:invalid_id_token, "invalid #{invalid_claim}") if invalid_claim

        claims
      rescue JSON::JWT::Exception => e
        raise CallbackError.new(:invalid_id_token, e.message)
      end

      def invalid_id_token_claim(claims)
        nonce_valid = expected_nonce?(claims['nonce'])

        {
          'iss' => claims['iss'] == discovered_configuration['issuer'],
          'aud' => Array(claims['aud']).include?(options[:client_id]),
          'exp' => unexpired?(claims['exp']),
          'nonce' => nonce_valid
        }.key(false)
      end

      def unexpired?(expiry)
        expiry.to_i + ID_TOKEN_EXPIRY_LEEWAY.to_i > Time.now.to_i
      end

      def expected_nonce?(nonce)
        expected_nonce = session.delete(nonce_session_key).to_s

        expected_nonce.present? && ActiveSupport::SecurityUtils.secure_compare(nonce.to_s, expected_nonce)
      end

      def decode_id_token
        return JSON::JWT.decode(raw_id_token.to_s, :skip_verification) unless Setting.fetch(:proconnect_id_token_signature_check)

        algorithm = id_token_algorithm
        raise CallbackError.new(:invalid_id_token, unexpected_algorithm_message(algorithm)) unless ID_TOKEN_SIGNING_ALGORITHMS.include?(algorithm)

        Rails.logger.info("[ProConnect] id_token signed with #{algorithm}")
        JSON::JWT.decode(raw_id_token.to_s, id_token_verification_key(algorithm), [algorithm.to_sym])
      end

      def id_token_verification_key(algorithm)
        return provider_signing_keys unless algorithm == 'HS256'

        options[:client_secret].presence || raise(CallbackError.new(:invalid_id_token, 'missing client secret for HS256'))
      end

      def unexpected_algorithm_message(algorithm)
        "unexpected id_token alg #{algorithm.presence || 'none'}, expected #{ID_TOKEN_SIGNING_ALGORITHMS.join('/')}"
      end

      def id_token_algorithm
        JSON::JWT.decode(raw_id_token.to_s, :skip_verification).alg.to_s
      end

      def provider_signing_keys
        JSON::JWK::Set.new(connection.get(URI(discovered_configuration['jwks_uri'])).body)
      end

      def id_token_claims
        @id_token_claims || {}
      end

      def store_tokens!(response)
        @access_token = response.body['access_token']
        @id_token = response.body['id_token']

        response
      end

      def get_userinfo!
        connection.get(URI(discovered_configuration['userinfo_endpoint']), {}, 'Authorization' => "Bearer #{@access_token}")
      end

      def raw_id_token
        @id_token
      end

      def id_token_session_key
        'omniauth.pc.id_token'
      end

      def state_session_key
        'omniauth.state'
      end

      def nonce_session_key
        'omniauth.nonce'
      end

      def store_new_state!
        session[state_session_key] = SecureRandom.hex(16)
      end

      def current_state
        session[state_session_key]
      end

      def store_new_nonce!
        session[nonce_session_key] = SecureRandom.hex(16)
      end

      def authorization_uri
        URI(discovered_configuration['authorization_endpoint']).tap do |endpoint|
          endpoint.query = URI.encode_www_form(authorization_params)
        end
      end

      def authorization_params
        {
          response_type: 'code',
          client_id: options[:client_id],
          redirect_uri: options[:redirect_uri],
          scope: options[:scope],
          state: store_new_state!,
          nonce: store_new_nonce!,
          claims: requested_claims.to_json
        }
      end

      def requested_claims
        {
          id_token: {
            acr: { essential: true, values: MFA_ACR_VALUES }
          }
        }
      end
    end
  end
end

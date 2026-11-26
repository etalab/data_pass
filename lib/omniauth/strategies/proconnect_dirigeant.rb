require Rails.root.join('lib/omniauth/strategies/data_pass_proconnect').to_s

module OmniAuth
  module Strategies
    class ProconnectDirigeant < DataPassProconnect
      DIRIGEANT_ACR_VALUE = 'https://proconnect.gouv.fr/assurance/certification-dirigeant'.freeze
      SIRET_FORMAT = /\A\d{14}\z/
      CHAINED_REQUEST_SESSION_KEY = 'omniauth.pc_dirigeant.chained_request'.freeze
      CHAINED_REQUEST_TTL = 2.minutes

      option :name, 'proconnect_dirigeant'

      def request_call?
        super || chained_request?
      end

      def other_phase
        call_app!
      end

      private

      def chained_request?
        on_request_path? && request.get? && fresh_chain?(session.delete(CHAINED_REQUEST_SESSION_KEY))
      end

      def fresh_chain?(chained_at)
        chained_at.is_a?(Integer) && Time.now.to_i - chained_at <= CHAINED_REQUEST_TTL.to_i
      end

      def authorization_params
        siret_hint = request.params['siret_hint'].to_s

        siret_hint.match?(SIRET_FORMAT) ? super.merge(siret_hint:) : super
      end

      def requested_claims
        {
          id_token: {
            acr: { essential: true, values: [DIRIGEANT_ACR_VALUE] },
            amr: nil
          }
        }
      end

      def keeps_id_token_for_logout?
        false
      end

      def state_session_key
        'omniauth.pc_dirigeant.state'
      end

      def nonce_session_key
        'omniauth.pc_dirigeant.nonce'
      end
    end
  end
end

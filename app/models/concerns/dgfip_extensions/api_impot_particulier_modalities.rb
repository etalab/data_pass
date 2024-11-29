module DGFIPExtensions::APIImpotParticulierModalities
  extend ActiveSupport::Concern

  MODALITIES = %w[with_france_connect with_spi with_etat_civil].freeze

  included do
    include AuthorizationExtensions::Modalities

    add_attribute :france_connect_authorization_id

    validates :france_connect_authorization_id,
      presence: true,
      inclusion: { in: ->(authorization_request) { authorization_request.organization.valid_authorizations_of(AuthorizationRequest::FranceConnect).pluck(:id).map(&:to_s) } },
      if: -> { modalities == 'with_france_connect' && need_complete_validation?(:modalities) }
  end

  def associated_france_connect_authorization
    return nil if france_connect_authorization_id.blank?

    Authorization.find(france_connect_authorization_id)
  end
end

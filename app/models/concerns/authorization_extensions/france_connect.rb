module AuthorizationExtensions::FranceConnect
  extend ActiveSupport::Concern

  included do
    add_attribute :france_connect_authorization_id

    validates :france_connect_authorization_id,
      presence: true,
      inclusion: { in: ->(authorization_request) { authorization_request.organization.valid_authorizations_of(AuthorizationRequest::FranceConnect).pluck(:id).map(&:to_s) } },
      if: -> { need_complete_validation?(:france_connect) }
  end

  def france_connect_authorization
    return nil if france_connect_authorization_id.blank?

    Authorization.find(france_connect_authorization_id)
  end
end

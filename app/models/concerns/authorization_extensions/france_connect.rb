module AuthorizationExtensions::FranceConnect
  extend ActiveSupport::Concern

  included do
    add_attribute :france_connect_authorization_id

    validates :france_connect_authorization_id,
      presence: true,
      if: -> { need_complete_validation?(:france_connect) && requires_france_connect_authorization? }

    validates :france_connect_authorization_id,
      inclusion: { in: ->(authorization_request) { authorization_request.organization.valid_authorizations_of(AuthorizationRequest::FranceConnect).pluck(:id).map(&:to_s) } },
      if: -> { france_connect_authorization_id.present? }
  end

  def france_connect_authorization
    return nil if france_connect_authorization_id.blank?

    Authorization.find(france_connect_authorization_id)
  end

  def with_france_connect?
    true
  end

  private

  def requires_france_connect_authorization?
    true
  end
end

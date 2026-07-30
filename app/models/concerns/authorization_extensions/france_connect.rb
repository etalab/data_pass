module AuthorizationExtensions::FranceConnect
  extend ActiveSupport::Concern

  included do
    add_attribute :france_connect_authorization_id

    validates :france_connect_authorization_id,
      presence: true,
      if: -> { requires_france_connect_authorization? }

    validates :france_connect_authorization_id,
      inclusion: { in: ->(authorization_request) { authorization_request.organization.valid_authorizations_of(AuthorizationRequest::FranceConnect).pluck(:id).map(&:to_s) } },
      if: -> { with_france_connect? && france_connect_authorization_id.present? }

    before_save :remove_france_connect_authorization_id_unless_with_france_connect
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
    need_complete_validation?(:france_connect)
  end

  def remove_france_connect_authorization_id_unless_with_france_connect
    self.france_connect_authorization_id = nil unless with_france_connect?
  end
end

module WalletRegistryPage
  extend ActiveSupport::Concern

  included do
    helper_method :wallet_registry_page?
  end

  private

  def wallet_registry_page?
    [
      @authorization_definition,
      @authorization_request_form.try(:authorization_definition),
      @authorization_request.try(:definition),
    ].compact.any? { |definition| definition.applicant_eligibility == 'wallet_registry' }
  end
end

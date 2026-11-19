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
    ].compact.any?(&:wallet_registry?)
  end
end

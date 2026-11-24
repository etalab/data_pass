class Molecules::WalletRegistry::OrganizationSummaryComponent < ApplicationComponent
  include Molecules::WalletRegistry::IdentityFormatting

  def initialize(authorization_request:)
    @authorization_request = authorization_request
  end

  private

  attr_reader :authorization_request

  def sirene_available?
    %i[sirene non_diffusible].include?(authorization_request.wallet_identity_source)
  end

  def legal_name
    authorization_request.identity_legal_name.presence || missing_identity_value
  end

  def address
    return formatted_address if authorization_request.wallet_identity_source == :sirene

    authorization_request.wallet_postal_address.presence || missing_identity_value
  end

  def missing_identity_value
    authorization_request.identity_pending? ? t('.loading') : t('.not_filled')
  end

  def support_channels
    [
      authorization_request.wallet_support_url,
      authorization_request.wallet_support_email,
      helpers.wallet_registry_phone(authorization_request.wallet_support_phone).presence,
    ].compact_blank
  end

  def not_registered_elsewhere
    authorization_request.wallet_not_registered_elsewhere ? t('.declared') : t('.not_declared')
  end

  def value_or_not_filled(value)
    value.presence || t('.not_filled')
  end
end

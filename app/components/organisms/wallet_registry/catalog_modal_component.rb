class Organisms::WalletRegistry::CatalogModalComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def initialize(authorization_request:, use:)
    @authorization_request = authorization_request
    @use = use
  end

  private

  attr_reader :authorization_request, :use

  def modal_id
    "wallet-catalog-#{use.id}"
  end

  def catalog_url
    authorization_request_form_wallet_rulebooks_path(form_uid: authorization_request.form_uid, authorization_request_id: authorization_request.id, intended_use_id: use.id)
  end

  def open_catalog_label
    safe_join([wallet_intended_uses_t('catalog.open'), tag.span(" #{wallet_intended_uses_t('catalog.for_sr', name: use.display_name)}", class: 'fr-sr-only')])
  end
end

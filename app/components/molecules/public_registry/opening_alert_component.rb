class Molecules::PublicRegistry::OpeningAlertComponent < ApplicationComponent
  def initialize(wallet_page_url:)
    @wallet_page_url = wallet_page_url
  end

  def call
    render DsfrComponent::AlertComponent.new(type: :info, title: t('.title'), header_level: 2) do
      safe_join([t('.text'), ' ', link_to(t('.link'), @wallet_page_url, class: 'fr-link')])
    end
  end
end

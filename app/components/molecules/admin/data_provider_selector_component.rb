class Molecules::Admin::DataProviderSelectorComponent < ApplicationComponent
  def initialize(data_providers:, selected_provider_id: nil, show_form: false, form_data_provider: DataProvider.new)
    @data_providers = data_providers
    @selected_provider_id = selected_provider_id
    @show_form = show_form
    @form_data_provider = form_data_provider
  end

  private

  attr_reader :data_providers, :selected_provider_id, :show_form, :form_data_provider
end

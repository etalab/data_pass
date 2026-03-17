class Molecules::Admin::DataProviderSelectorComponentPreview < ViewComponent::Preview
  def default
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all
    )
  end

  def with_selection
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all,
      selected_provider_id: DataProvider.first&.id
    )
  end

  def with_form_open
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all,
      show_form: true,
      form_data_provider: DataProvider.new
    )
  end

  def with_form_errors
    dp = DataProvider.new
    dp.errors.add(:name, :blank)
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all,
      show_form: true,
      form_data_provider: dp
    )
  end
end

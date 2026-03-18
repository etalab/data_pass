class Molecules::Admin::DataProviderFormComponentPreview < ViewComponent::Preview
  def standalone_new
    render Molecules::Admin::DataProviderFormComponent.new(
      data_provider: DataProvider.new
    )
  end

  def standalone_edit
    render Molecules::Admin::DataProviderFormComponent.new(
      data_provider: DataProvider.first
    )
  end

  def inline
    render Molecules::Admin::DataProviderFormComponent.new(
      data_provider: DataProvider.new,
      inline: true
    )
  end

  def inline_with_errors
    dp = DataProvider.new
    dp.errors.add(:name, :blank)
    dp.errors.add(:link, :blank)
    render Molecules::Admin::DataProviderFormComponent.new(data_provider: dp, inline: true)
  end
end

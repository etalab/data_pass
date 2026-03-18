class Admin::DestroyDataProviderRecord < ApplicationInteractor
  def call
    context.data_provider.destroy!
  end
end

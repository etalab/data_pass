# frozen_string_literal: true

class Molecules::Admin::DataProviderFormComponent < ApplicationComponent
  def initialize(data_provider:, inline: false)
    @data_provider = data_provider
    @inline = inline
  end

  private

  attr_reader :data_provider, :inline

  def inline?
    inline
  end

  def submit_label
    if data_provider.persisted?
      t('admin.data_providers.form.update')
    else
      t('admin.data_providers.form.submit')
    end
  end
end

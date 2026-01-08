class FlashAlertComponent < ApplicationComponent
  def initialize(type:, data:, close_button: true)
    @type = type
    @data = data
    @close_button = close_button
    super()
  end

  def call
    if tiny?
      render_tiny_alert
    else
      render_standard_alert
    end
  end

  private

  attr_reader :type, :data, :close_button

  def tiny?
    data['tiny'].present?
  end

  def render_tiny_alert
    helpers.dsfr_alert(type:, size: :sm, close_button: true, html_attributes: { class: 'fr-alert--tiny' }) do
      data['title']
    end
  end

  def render_standard_alert
    helpers.dsfr_alert(type:, title: data['title'], close_button:, html_attributes: { class: 'fr-my-8v' }) do
      safe_join([description_content, errors_content].compact)
    end
  end

  def description_content
    return if data['description'].blank?

    data['description']
  end

  def errors_content
    return if data['errors'].blank?

    tag.ul do
      safe_join(data['errors'].map { |error| tag.li(error) })
    end
  end
end

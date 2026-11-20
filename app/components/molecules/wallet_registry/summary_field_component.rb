class Molecules::WalletRegistry::SummaryFieldComponent < ApplicationComponent
  COLUMNS = {
    third: 'fr-col-12 fr-col-md-6 fr-col-lg-4',
    half: 'fr-col-12 fr-col-md-6',
    full: 'fr-col-12'
  }.freeze

  def initialize(label:, value: nil, width: :third)
    @label = label
    @value = value
    @width = width
  end

  def call
    tag.div(class: COLUMNS.fetch(@width)) do
      tag.div(class: 'contact-card__attribute') do
        safe_join([tag.div(@label, class: 'contact-card__attribute-label'), tag.div(content || @value, class: 'contact-card__attribute-value')])
      end
    end
  end
end

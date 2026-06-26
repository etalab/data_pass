class Molecules::Instruction::Form::ConfigBlockComponent < Atoms::ConfigBlockComponent
  def initialize(form:)
    @form = form
  end

  private

  attr_reader :form

  def rows
    [service_provider_row, *boolean_rows]
  end

  def service_provider_row
    value = if form.service_provider
              tag.strong(service_provider_label)
            else
              tag.span(t('.no_service_provider'), class: 'fr-text-mention--grey')
            end

    { label: t('.fields.service_provider'), value: }
  end

  def boolean_rows
    [
      boolean_row(t('.fields.public'), form.public),
      boolean_row(t('.fields.startable_by_applicant'), form.startable_by_applicant),
      boolean_row(t('.fields.single_page_view'), form.single_page_view.present?)
    ]
  end

  def service_provider_label
    sp = form.service_provider

    if sp.editor?
      "#{t('.service_provider_types.editor')} : #{sp.name}"
    elsif sp.saas?
      "#{t('.service_provider_types.saas')} : #{sp.name}"
    else
      sp.name
    end
  end
end

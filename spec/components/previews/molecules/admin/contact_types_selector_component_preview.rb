class Molecules::Admin::ContactTypesSelectorComponentPreview < ViewComponent::Preview
  def all_checked
    record = HabilitationType.new(
      contact_types: Molecules::Admin::ContactTypesSelectorComponent::CONTACT_TYPES
    )
    render Molecules::Admin::ContactTypesSelectorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Types de contacts'
    )
  end

  def none_checked
    record = HabilitationType.new(contact_types: [])
    render Molecules::Admin::ContactTypesSelectorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Types de contacts'
    )
  end

  def partial_selection
    record = HabilitationType.first
    render Molecules::Admin::ContactTypesSelectorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Types de contacts'
    )
  end

  private

  def create_form_builder(record)
    DsfrFormBuilder.new(
      :habilitation_type,
      record,
      ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil),
      {}
    )
  end
end

class Molecules::Admin::ScopesEditorComponentPreview < ViewComponent::Preview
  def with_scopes
    record = HabilitationType.new(
      scopes: [
        { 'name' => 'Revenu fiscal', 'value' => 'rfr', 'group' => 'Revenus' },
        { 'name' => 'Adresse', 'value' => 'adresse', 'group' => 'Coordonnees' },
      ]
    )
    render Molecules::Admin::ScopesEditorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record
    )
  end

  def empty
    record = HabilitationType.new(scopes: [])
    render Molecules::Admin::ScopesEditorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record
    )
  end

  def with_errors
    record = HabilitationType.new(
      blocks: [{ 'name' => 'scopes' }],
      scopes: [
        { 'name' => '', 'value' => '', 'group' => '' },
        { 'name' => 'Adresse', 'value' => 'adresse', 'group' => 'Coordonnees' },
      ]
    )
    record.validate
    render Molecules::Admin::ScopesEditorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record
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

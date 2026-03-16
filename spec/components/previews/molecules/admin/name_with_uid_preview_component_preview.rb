class Molecules::Admin::NameWithUidPreviewComponentPreview < ViewComponent::Preview
  def new_record
    record = HabilitationType.new
    render Molecules::Admin::NameWithUidPreviewComponent.new(
      form: create_form_builder(record),
      record: record,
      uid_label: 'Identifiant technique'
    )
  end

  def existing_record
    record = HabilitationType.first
    render Molecules::Admin::NameWithUidPreviewComponent.new(
      form: create_form_builder(record),
      record: record,
      uid_label: 'Identifiant technique'
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

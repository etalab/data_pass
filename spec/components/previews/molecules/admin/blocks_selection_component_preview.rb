class Molecules::Admin::BlocksSelectionComponentPreview < ViewComponent::Preview
  def all_checked
    record = HabilitationType.new(blocks: HabilitationType::BLOCK_ORDER)
    render Molecules::Admin::BlocksSelectionComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Blocs'
    )
  end

  def partial_selection
    record = HabilitationType.first
    render Molecules::Admin::BlocksSelectionComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Blocs'
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

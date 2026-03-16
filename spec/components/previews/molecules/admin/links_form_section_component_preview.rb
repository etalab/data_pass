# frozen_string_literal: true

class Molecules::Admin::LinksFormSectionComponentPreview < ViewComponent::Preview
  def default
    record = HabilitationType.first
    render Molecules::Admin::LinksFormSectionComponent.new(
      form: create_form_builder(record)
    )
  end

  def new_record
    record = HabilitationType.new
    render Molecules::Admin::LinksFormSectionComponent.new(
      form: create_form_builder(record)
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

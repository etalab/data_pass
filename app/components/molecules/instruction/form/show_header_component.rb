class Molecules::Instruction::Form::ShowHeaderComponent < ApplicationComponent
  include Molecules::Instruction::Breadcrumb

  def initialize(authorization_definition:, form:, validated_count:, submitted_count:, can_initiate_request: false)
    @authorization_definition = authorization_definition
    @form = form
    @validated_count = validated_count
    @submitted_count = submitted_count
    @can_initiate_request = can_initiate_request
  end

  private

  attr_reader :authorization_definition, :form, :validated_count, :submitted_count, :can_initiate_request

  def breadcrumbs
    [
      formulaires_breadcrumb_item,
      authorization_definition_breadcrumb_item,
      { label: I18n.t('instruction.forms.show.title'),
        href: helpers.instruction_authorization_definition_forms_path(authorization_definition) },
      { label: form.name }
    ]
  end

  def initiate_request_path
    return unless can_initiate_request

    helpers.start_instruction_instructor_draft_requests_path(form_uid: form.uid)
  end

  def request_url
    helpers.new_authorization_request_form_url(form_uid: form.uid)
  end
end

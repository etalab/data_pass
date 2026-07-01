class Molecules::Instruction::Form::ShowHeaderComponent < ApplicationComponent
  def initialize(authorization_definition:, form:, validated_count:, submitted_count:, can_initiate_request: false)
    @authorization_definition = authorization_definition
    @form = form
    @validated_count = validated_count
    @submitted_count = submitted_count
    @can_initiate_request = can_initiate_request
  end

  private

  attr_reader :authorization_definition, :form, :validated_count, :submitted_count, :can_initiate_request

  def back_link
    {
      path: helpers.instruction_authorization_definition_forms_path(authorization_definition),
      text: I18n.t('instruction.forms.show.title')
    }
  end

  def initiate_request_path
    return unless can_initiate_request

    helpers.start_instruction_instructor_draft_requests_path(form_uid: form.uid)
  end

  def request_url
    helpers.new_authorization_request_form_url(form_uid: form.uid)
  end
end

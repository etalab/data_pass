class Molecules::Instruction::AuthorizationDefinition::ShowHeaderComponent < ApplicationComponent
  def initialize(authorization_definition:, validated_count:, submitted_count:)
    @authorization_definition = authorization_definition
    @validated_count = validated_count
    @submitted_count = submitted_count
  end

  private

  attr_reader :authorization_definition, :validated_count, :submitted_count

  def back_link
    {
      path: helpers.instruction_authorization_definitions_path,
      text: I18n.t('page_titles.instruction_definitions')
    }
  end

  def initiate_request_path
    return unless helpers.policy([:instruction, authorization_definition]).initiate_request?

    helpers.start_instruction_instructor_draft_requests_path(
      form_uid: authorization_definition.default_form.uid
    )
  end

  def request_url
    helpers.new_authorization_request_url(authorization_definition.id)
  end
end

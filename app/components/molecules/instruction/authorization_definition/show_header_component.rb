class Molecules::Instruction::AuthorizationDefinition::ShowHeaderComponent < ApplicationComponent
  include Molecules::Instruction::Breadcrumb

  def initialize(authorization_definition:, validated_count:, submitted_count:, can_initiate_request: false)
    @authorization_definition = authorization_definition
    @validated_count = validated_count
    @submitted_count = submitted_count
    @can_initiate_request = can_initiate_request
  end

  private

  attr_reader :authorization_definition, :validated_count, :submitted_count, :can_initiate_request

  def breadcrumbs
    [
      formulaires_breadcrumb_item,
      authorization_definition_breadcrumb_item(link: false)
    ]
  end

  def initiate_request_path
    return unless can_initiate_request

    helpers.start_instruction_instructor_draft_requests_path(
      form_uid: authorization_definition.default_form.uid
    )
  end

  def request_url
    helpers.new_authorization_request_url(authorization_definition.id)
  end
end

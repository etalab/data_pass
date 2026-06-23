class Molecules::Instruction::AuthorizationDefinition::CardComponent < ApplicationComponent
  def initialize(authorization_definition:, validated_count:, submitted_count:)
    @authorization_definition = authorization_definition
    @validated_count = validated_count
    @submitted_count = submitted_count
  end

  private

  attr_reader :authorization_definition, :validated_count, :submitted_count

  delegate :name_with_stage, :provider, to: :authorization_definition
end

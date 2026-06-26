class Molecules::Instruction::AuthorizationDefinition::FormCardComponent < ApplicationComponent
  def initialize(authorization_request_form:, validated_count:, submitted_count:)
    @authorization_request_form = authorization_request_form
    @validated_count = validated_count
    @submitted_count = submitted_count
  end

  private

  attr_reader :authorization_request_form, :validated_count, :submitted_count

  delegate :name, :uid, :use_case, :default, to: :authorization_request_form

  def use_case_pictogram_path
    "pictograms/authorization_requests/#{use_case}.svg"
  end

  def use_case_pictogram?
    use_case.present? && Rails.root.join("app/assets/images/#{use_case_pictogram_path}").exist?
  end
end

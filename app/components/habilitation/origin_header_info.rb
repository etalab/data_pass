class Habilitation::OriginHeaderInfo < ApplicationComponent
  include Rails.application.routes.url_helpers

  def initialize(authorization:)
    @authorization = authorization
    super
  end

  def call
    tag.div(class: 'fr-pb-3w fr-pl-1w fr-text-inverted--blue-france') do
      translation.html_safe
    end
  end

  private

  attr_reader :authorization

  delegate :auto_generated?, to: :authorization

  def approving_instructor
    if auto_generated?
      authorization.parent_authorization&.approving_instructor
    else
      authorization.approving_instructor
    end
  end

  def translation
    I18n.t("authorizations.instruction_header_info.#{translation_key}_html", **translation_params)
  end

  def translation_key
    if auto_generated?
      auto_generated_translation_key
    elsif form_name && approving_instructor
      'with_form_and_instructor'
    elsif form_name
      'with_form'
    elsif approving_instructor
      'without_form_and_instructor'
    else
      'without_form'
    end
  end

  def auto_generated_translation_key
    if form_name && approving_instructor
      'auto_generated_with_form_and_instructor'
    elsif form_name
      'auto_generated_with_form'
    elsif approving_instructor
      'auto_generated_and_instructor'
    else
      'auto_generated'
    end
  end

  def translation_params
    params = { request_link: request_link }
    params[:form_name] = form_name if form_name
    params[:email] = approving_instructor.email if approving_instructor
    params
  end

  def request_link
    link_to(
      "demande #{authorization.request.formatted_id}",
      instruction_authorization_request_authorizations_path(authorization.request),
      class: 'fr-link fr-text-inverted--blue-france'
    )
  end

  def form_name
    @form_name ||= authorization.form&.name
  end
end

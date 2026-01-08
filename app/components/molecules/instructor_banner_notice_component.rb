class Molecules::InstructorBannerNoticeComponent < ApplicationComponent
  NOTICE_CLASSES = 'fr-notice--full-width fr-notice--multi-lines fr-mb-4w'.freeze

  def initialize(authorization_request:)
    @authorization_request = authorization_request
    super()
  end

  def render?
    authorization_request.changes_requested? || authorization_request.refused?
  end

  def call
    render DsfrComponent::NoticeComponent.new(
      title:,
      description:,
      type: notice_type.to_s,
      html_attributes: { class: NOTICE_CLASSES }
    )
  end

  private

  attr_reader :authorization_request

  def notice_type
    return :alert if authorization_request.refused? || reopening_with_denial?
    return :warning if authorization_request.changes_requested?

    nil
  end

  def reopening_with_denial?
    authorization_request.reopening? && authorization_request.denial.present?
  end

  def title
    I18n.t("#{i18n_key}.title")
  end

  def description
    base_description = I18n.t("#{i18n_key}.description")
    return base_description if reason.blank?

    safe_join([
      base_description,
      tag.br,
      helpers.simple_format(reason, {}, wrapper_tag: 'span')
    ])
  end

  def reason
    return authorization_request.modification_request&.reason if authorization_request.changes_requested?
    return authorization_request.denial&.reason if notice_type == :alert

    nil
  end

  def i18n_key
    key = if authorization_request.reopening?
            notice_type == :alert ? 'reopening_refused' : 'reopening_changes_requested'
          elsif notice_type == :alert
            'refused'
          else
            'changes_requested'
          end
    "authorization_requests.show.#{key}"
  end
end

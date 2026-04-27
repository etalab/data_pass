class AuthorizationRequestMailer < ApplicationMailer
  %i[approve refuse request_changes revoke submit].each do |event|
    [event, "reopening_#{event}"].each do |mth|
      next if mth == 'reopening_revoke'

      define_method(mth) do
        @authorization_request = params[:authorization_request]

        mail(
          to: @authorization_request.applicant.email,
          subject: t(
            '.subject',
            authorization_request_id: @authorization_request.formatted_id,
          )
        ) do |format|
          format.text { render text_template_path_for(@authorization_request.kind, mth) }
          html_path = html_template_path_for(@authorization_request.kind, mth)
          format.html { render html_path } if html_path
        end
      end
    end
  end

  private

  def text_template_path_for(kind, action)
    return "authorization_request_mailer/#{kind}/#{action}" if text_template_exists?(kind, action)

    "authorization_request_mailer/#{action}"
  end

  def text_template_exists?(kind, action)
    lookup_context.exists?(
      "#{kind}/#{action}",
      ['authorization_request_mailer'],
      false,
      [],
      formats: [:text],
    )
  end

  def html_template_path_for(kind, action)
    return "authorization_request_mailer/#{kind}/#{action}" if html_template_exists?(kind, action)
    return "authorization_request_mailer/#{action}" if generic_html_template_exists?(action)

    nil
  end

  def html_template_exists?(kind, action)
    lookup_context.exists?(
      "#{kind}/#{action}",
      ['authorization_request_mailer'],
      false,
      [],
      formats: [:html],
    )
  end

  def generic_html_template_exists?(action)
    lookup_context.exists?(
      action,
      ['authorization_request_mailer'],
      false,
      [],
      formats: [:html],
    )
  end
end

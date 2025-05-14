module AuthorizationRequestsHelpers
  include DemandesHabilitations::CommonHelper

  # rubocop:disable Rails/HelperInstanceVariable
  def new_authorization_request_hidden_params
    return { attributes: {} } if @authorization_request&.persisted? || params.slice(:attributes).blank?

    params.slice(:attributes).permit!
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def start_authorization_request_form(form, disabled: false)
    text = t('start_authorization_request_form.cta', authorization_name: form.authorization_definition.name)
    css_classes = %w[fr-btn fr-icon-save-line fr-btn--icon-left]

    if disabled
      button_tag(text, class: css_classes, disabled: true, id: dom_id(form, :start_authorization_request))
    else
      link_to(text, start_authorization_request_forms_path(form_uid: form.id, params: new_authorization_request_hidden_params), class: css_classes, id: dom_id(form, :start_authorization_request))
    end
  end

  def authorization_request_form(authorization_request, url: nil, form_options: {}, &)
    authorization_request_form_tag(authorization_request, url:, form_options:) do |f|
      render(layout: 'authorization_request_forms/form', locals: { f: }) do
        yield f
      end
    end
  end

  def within_wizard?
    build_controller? ||
      authorization_request_first_step_build?
  end

  def within_edit?
    action_name == 'edit'
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def within_summary?
    @summary_before_submit.present?
  end
  # rubocop:enable Rails/HelperInstanceVariable

  # rubocop:disable Rails/HelperInstanceVariable
  def english_step_name(translated_step_key = nil)
    if translated_step_key.nil?
      @authorization_request.form.steps.first[:name]
    else
      I18n.t('wicked').select { |_k, v| v == translated_step_key }.keys.first
    end
  end
  # rubocop:enable Rails/HelperInstanceVariable

  private

  def build_controller?
    controller_name == 'build' &&
      action_name == 'show'
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def authorization_request_first_step_build?
    @authorization_request.form.multiple_steps? &&
      controller_name == 'authorization_request_forms' &&
      action_name == 'start'
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def authorization_request_form_tag(authorization_request, url: nil, form_options: {}, &)
    form_with(
      **form_options.merge(
        model: authorization_request,
        url: url || authorization_request_model_path(authorization_request),
        method: authorization_request_model_http_method(authorization_request),
        id: dom_id(authorization_request),
        builder: authorization_request_can_be_updated?(authorization_request) ? AuthorizationRequestFormBuilder : DisabledAuthorizationRequestFormBuilder
      ),
      &
    )
  end

  def authorization_request_model_path(authorization_request)
    if namespace?(:instruction)
      '#'
    elsif authorization_request.new_record?
      authorization_request_forms_path(form_uid: authorization_request.form.uid)
    elsif authorization_request.form.multiple_steps? && defined?(wizard_path)
      wizard_path
    else
      authorization_request_form_path(form_uid: authorization_request.form.uid, id: authorization_request.id)
    end
  end

  def authorization_request_model_http_method(authorization_request)
    return if namespace?(:instruction)

    if authorization_request.new_record?
      :post
    else
      :patch
    end
  end

  def authorization_request_can_be_updated?(authorization_request)
    return false if namespace?(:instruction)

    authorization_request.filling?
  end

  def render_custom_editable_block_or_default(authorization_request, block_id, locals = {})
    render partial: "authorization_request_forms/blocks/#{authorization_request.definition.id}/#{block_id}", locals: { authorization_request:, **locals }
  rescue ActionView::MissingTemplate
    render partial: "authorization_request_forms/blocks/default/#{block_id}", locals: { authorization_request:, **locals }
  end
end

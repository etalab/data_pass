class AuthorizationRequestFormBuilder < DSFRFormBuilder
  include DSFR::Accordion

  def hint_for(attribute)
    wording_for(:hint, attribute) ||
      super(attribute)
  end

  def label_value(attribute)
    wording_for(:label, attribute) ||
      super(attribute)
  end

  def wording_for(kind, attribute)
    I18n.t("authorization_request_forms.#{@object.model_name.element}.#{attribute}.#{kind}", default: nil) ||
      I18n.t("authorization_request_forms.default.#{attribute}.#{kind}", default: nil)
  end

  def info_for(block)
    info_wording = wording_for(:info, block)

    return unless info_wording
    return unless %i[title content].all? { |key| info_wording.key?(key) }

    dsfr_accordion(
      info_wording[:title],
      info_wording[:content],
      {
        id: [@object.model_name.element, 'info', block].join('_'),
        class: %w[fr-accordion--info fr-mb-3w],
      },
    )
  end

  def contacts_infos(contacts = nil)
    contacts ||= @object.class.contact_types

    dsfr_accordion(
      I18n.t('authorization_request_forms.default.contacts.info.title'),
      contacts.map do |contact|
        '<p>' +
          (I18n.t("authorization_request_forms.#{@object.model_name.element}.#{contact}.info", default: nil) ||
            I18n.t("authorization_request_forms.default.#{contact}.info")) +
          '</p>'
      end.join,
      {
        id: [@object.model_name.element, 'info_contacts'].join('_'),
        class: %w[fr-accordion--info fr-mb-3w],
      },
    )
  end

  def dsfr_file_field(attribute, opts = {})
    dsfr_input_group(attribute, opts) do
      @template.safe_join(
        [
          label_with_hint(attribute),
          readonly? ? nil : file_field(attribute, class: input_classes(opts), autocomplete: 'off', **enhance_input_options(opts).except(:class)),
          error_message(attribute),
          link_to_file(attribute)
        ].compact
      )
    end
  end

  def dsfr_scope(scope, opts = {})
    @template.content_tag(:div, class: 'fr-checkbox-group') do
      @template.safe_join(
        [
          check_box(
            :scopes,
            {
              class: input_classes(opts),
              **dsfr_scope_options(scope),
              **enhance_input_options(opts).except(:class)
            },
            scope.value,
            nil
          ),
          dsfr_scope_label(scope),
          scope.included? ? scope_hidden_field(scope) : nil
        ].compact
      )
    end
  end

  def dsfr_scope_options(scope)
    {
      disabled: check_box_disabled || scope.included?,
      checked: scope.included? || @object.scopes.include?(scope.value),
      multiple: true,
    }
  end

  def dsfr_scope_label(scope)
    label(:scopes, class: 'fr-label', value: scope.value) do
      @template.safe_join(
        [
          scope.name,
          scope.link? ? @template.link_to('', scope.link, { target: '_blank', rel: 'noopener' }) : nil
        ].compact
      )
    end
  end

  def scope_hidden_field(scope)
    hidden_field(:scopes, value: scope.value, name: "#{@object.model_name.param_key}[scopes][]")
  end

  def link_to_file(attribute)
    link_to_file = super(attribute)

    if link_to_file.present?
      link_to_file
    elsif readonly?
      I18n.t('form.no_file')
    else
      ''
    end
  end

  def enhance_input_options(opts)
    super.merge(readonly: readonly?)
  end

  def readonly?
    !@object.in_draft?
  end

  def check_box_disabled
    readonly?
  end
end

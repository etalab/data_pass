class AuthorizationRequestFormBuilder < DSFRFormBuilder
  include DSFR::Accordion

  def hint_for(attribute)
    wording_for("#{attribute}.hint") ||
      super
  end

  def label_value(attribute)
    wording_for("#{attribute}.label").try(:html_safe) ||
      super
  end

  def wording_for(key, opts = {})
    opts[:default] = nil

    I18n.t("authorization_request_forms.#{@object.form.uid.underscore}.#{key}", **opts) ||
      I18n.t("authorization_request_forms.#{@object.model_name.element}.#{key}", **opts) ||
      I18n.t("authorization_request_forms.default.#{key}", **opts)
  end

  def info_for(block)
    return if @template.namespace?(:instruction)

    info_wording = {
      title: wording_for("#{block}.info.title"),
      content: wording_for("#{block}.info.content"),
    }

    return unless info_wording
    return unless %i[title content].all? { |key| info_wording[key].present? }

    dsfr_accordion(
      info_wording[:title],
      {
        id: [@object.model_name.element, 'info', block].join('_'),
        class: %w[fr-accordion--info fr-mb-5w],
      }
    ) do
      info_wording[:content]
    end
  end

  def contacts_infos(contacts = nil)
    return if @template.namespace?(:instruction)

    contacts ||= @object.contact_types

    dsfr_accordion(
      I18n.t('authorization_request_forms.default.contacts.info.title'),
      {
        id: [@object.model_name.element, 'info_contacts'].join('_'),
        class: %w[fr-accordion--info fr-mb-3w],
      }
    ) do
      contacts.reduce('') do |content, contact|
        contact_content = I18n.t("authorization_request_forms.#{@object.model_name.element}.#{contact}.info", default: nil) ||
                          I18n.t("authorization_request_forms.default.#{contact}.info")

        content << "<p>#{contact_content}</p>"
      end
    end
  end

  def cgu_check_box(_opts = {})
    term_checkbox(:terms_of_service_accepted) do |options|
      options[:label] = cgu_check_box_label
    end
  end

  def data_protection_officer_informed_check_box(_opts = {})
    term_checkbox(:data_protection_officer_informed)
  end

  def extra_checkboxes
    @object.extra_checkboxes
  rescue NoMethodError
    []
  end

  def term_checkbox(name, opts = {})
    opts[:required] = true
    opts[:class] ||= []
    opts[:class] << 'fr-input-group--error' if all_terms_not_accepted_error?(name)

    yield(opts) if block_given?

    dsfr_check_box(name, opts)
  end

  def dsfr_scope(scope, opts = {})
    disabled = opts.delete(:disabled)

    disabled = @object.disabled_scopes.include?(scope) if disabled.blank?

    @template.content_tag(:div, class: 'fr-checkbox-group') do
      @template.safe_join(
        [
          check_box(
            :scopes,
            {
              class: input_classes(opts),
              **dsfr_scope_options(scope, disabled:),
              **enhance_input_options(opts).except(:class)
            },
            scope.value,
            nil
          ),
          dsfr_scope_label(scope),
          include_scope_hidden_field?(scope, disabled) ? scope_hidden_field(scope) : nil
        ].compact
      )
    end
  end

  def include_scope_hidden_field?(scope, disabled)
    if disabled
      scope.included? ||
        @object.scopes.include?(scope.value)
    else
      scope.included?
    end
  end

  def dsfr_scope_options(scope, disabled: false)
    {
      disabled: disabled || check_box_disabled || scope.included? || scope.disabled?,
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

  def link_to_files(attribute)
    link_to_files = super

    if link_to_files.present?
      link_to_files
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
    !@object.filling?
  end

  def check_box_disabled
    readonly?
  end

  private

  def cgu_check_box_label
    label(
      :terms_of_service_accepted,
      [
        wording_for('terms_of_service_accepted.label', link: object.definition.cgu_link).html_safe,
        required_tag,
      ].join(' ').html_safe
    )
  end

  def all_terms_not_accepted_error?(attribute)
    return false if @object.public_send(attribute).present?

    @object.errors.any? do |error|
      error.attribute == :base && error.type == :all_terms_not_accepted
    end
  end
end

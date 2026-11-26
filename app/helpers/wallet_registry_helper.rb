module WalletRegistryHelper
  def wallet_registry_wizard_step?
    !within_summary?
  end

  def wallet_registry_body_data(authorization_request)
    data = { controller: 'field-format', field_format_messages_value: wallet_registry_field_format_messages }
    return data unless authorization_request.persisted?

    data.merge(
      controller: 'autosave field-format',
      autosave_url_value: authorization_request_form_autosave_path(form_uid: authorization_request.form_uid, authorization_request_id: authorization_request.id)
    )
  end

  def wallet_executive_certified(authorization_request)
    return if authorization_request.identity_public_sector.nil? || authorization_request.wallet_public_sector? || !FeatureFlag.enabled?(:proconnect_dirigeant)

    current_user.organizations_users.certified_dirigeant.exists?(organization: authorization_request.organization)
  end

  def wallet_registry_commitment_label(authorization_request)
    known_name = authorization_request.identity_legal_name.presence
    scope = 'authorization_request_forms.registre_wallet.wallet_not_registered_elsewhere'

    known_name ? t("#{scope}.label", organization_name: known_name) : t("#{scope}.label_unknown_name")
  end

  def wallet_registry_phone(value)
    digits = value.to_s.gsub(/[\s.()-]/, '')

    case digits
    when /\A(?:0|\+33)([1-9]\d{8})\z/ then wallet_registry_phone_pairs("0#{::Regexp.last_match(1)}")
    when /\A(\+(?:262|508|590|594|596|681|687|689))(\d{6,9})\z/ then "#{::Regexp.last_match(1)} #{wallet_registry_phone_pairs(::Regexp.last_match(2))}"
    else value
    end
  end

  def wallet_registry_current_step
    controller_name == 'build' ? english_step_name(params[:id]) : current_wizard_step_name
  end

  def wallet_registry_step_position(authorization_request)
    steps = authorization_request.form.steps.pluck(:name)

    { current: steps.index(wallet_registry_current_step.to_s).to_i + 1, total: steps.size }
  end

  def wallet_registry_flash_kinds(authorization_request)
    authorization_request.errors.any? ? %i[info success warning] : %i[error info success warning]
  end

  def wallet_registry_error_field_ids(form)
    { wallet_support: form.field_id(:wallet_support_url), identity_source: 'wallet-identity-refresh', identity_address: 'wallet-identity-refresh' }
  end

  def wallet_registry_field_format_messages
    scope = 'activerecord.errors.models.authorization_request/registre_wallet.attributes'

    {
      https_url: t("#{scope}.wallet_website_url.wallet_https_format"),
      email: t("#{scope}.wallet_support_email.wallet_email_format"),
      phone: t("#{scope}.wallet_support_phone.invalid_french_phone_format"),
    }.to_json
  end

  private

  def wallet_registry_phone_pairs(digits)
    digits.reverse.scan(/\d{1,2}/).map(&:reverse).reverse.join(' ')
  end
end

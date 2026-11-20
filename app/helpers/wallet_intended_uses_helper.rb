module WalletIntendedUsesHelper
  WORDING_SCOPE = 'authorization_request_forms.registre_wallet.wallet_intended_uses'.freeze
  PARAM_PREFIX = 'authorization_request_registre_wallet[wallet_intended_uses_attributes]'.freeze
  ID_PREFIX = 'authorization_request_registre_wallet_wallet_intended_uses_attributes'.freeze

  def wallet_intended_uses_t(key, **)
    t("#{WORDING_SCOPE}.#{key}", **)
  end

  def wallet_intended_use_dom_id(index, suffix)
    "#{ID_PREFIX}_#{index}_#{suffix}"
  end

  def wallet_attestation_param(index, attestation_index, key)
    "#{PARAM_PREFIX}[#{index}][requested_attestations_attributes][#{attestation_index}][#{key}]"
  end

  def wallet_intended_uses_command_url(authorization_request)
    authorization_request_form_wallet_intended_uses_path(form_uid: authorization_request.form_uid, authorization_request_id: authorization_request.id)
  end

  def wallet_intended_use_command_button(authorization_request, command, label, **)
    button_tag(label, type: 'submit', name: 'wallet_command', value: command, formaction: wallet_intended_uses_command_url(authorization_request), formnovalidate: true, **)
  end

  def wallet_intended_use_open?(authorization_request, use)
    return params[:ouverte] == use.id.to_s if params[:ouverte].present?
    return use.errors.any? if authorization_request.errors.any?

    authorization_request.active_wallet_intended_uses.last == use
  end

  def wallet_intended_use_focus?(use, key)
    params[:ouverte].present? ? params[:ouverte] == use.id.to_s && params[:focus] == key : false
  end

  def wallet_open_attestation(use)
    focused = use.attestations.find { |attestation| wallet_intended_use_focus?(use, "attestation_#{attestation.rulebook_id}") }

    focused || use.attestations.find { |attestation| use.claim_error_for(attestation) } || use.attestations.first
  end

  def wallet_intended_use_totals(use)
    return wallet_intended_uses_t('totals.none') if use.attestations.empty?

    [wallet_intended_uses_t('totals.attestations', count: use.attestations.size), wallet_intended_uses_t('totals.claims', count: use.claim_count)].join(', ')
  end

  def wallet_claim_mentions(attestation, claim)
    mentions = []
    mentions << wallet_intended_uses_t("attestation.presence.#{claim.requirement}") if claim.may_be_missing?
    mentions << wallet_intended_uses_t('attestation.single_format', format_name: wallet_claim_format_label(attestation, claim)) if attestation.formats.size > claim.format_count
    mentions
  end

  def wallet_claim_format_label(attestation, claim)
    format_ids = claim.paths.map(&:rulebook_format_id)
    attestation.formats.find { |format| format_ids.include?(format.id) }&.label
  end

  def wallet_attestation_technical_line(attestation)
    [
      wallet_intended_uses_t('attestation.category', category: attestation.category || wallet_intended_uses_t('attestation.category_unknown')),
      attestation.version_label,
      wallet_intended_uses_t('attestation.formats', count: attestation.formats.size, formats: attestation.format_labels.join(', '))
    ].join(' · ')
  end

  def wallet_selected_claims(attestation)
    attestation.selected_claims
  end

  def wallet_intended_uses_client_wordings
    {
      purposeCounter: wallet_intended_uses_t('fields.purpose.counter', count: '__count__', max: WalletRegistry::IntendedUse::PURPOSE_MAX_LENGTH),
      claimsCount: plural_wordings('attestation.claims_count'),
      groupCount: plural_wordings('attestation.group_count'),
      attestationsTotal: plural_wordings('totals.attestations'),
      claimsTotal: plural_wordings('totals.claims'),
      noAttestation: wallet_intended_uses_t('totals.none'),
      edit: wallet_intended_uses_t('card.edit'),
      collapse: wallet_intended_uses_t('card.collapse'),
      showClaims: wallet_intended_uses_t('attestation.show_claims'),
      hideClaims: wallet_intended_uses_t('attestation.hide_claims'),
      noData: wallet_intended_uses_t('preview.no_data'),
      noPurpose: wallet_intended_uses_t('preview.no_purpose'),
      errorSummaryTitle: error_summary_title_wordings
    }.to_json
  end

  def wallet_preview_privacy_policy(use)
    label = wallet_intended_uses_t('preview.privacy_policy')
    url = use.effective_privacy_policy_url
    return label unless url.present? && WalletRegistry::IntendedUse::HTTPS_URL_FORMAT.match?(url)

    link_to(url, target: '_blank', rel: 'noopener', title: wallet_intended_uses_t('preview.privacy_policy_title')) do
      safe_join([label, tag.span(wallet_intended_uses_t('new_window'), class: 'fr-sr-only')])
    end
  end

  def wallet_summary_period(use)
    return wallet_intended_uses_t('summary.period_missing') if use.start_date.blank?

    start = l(use.start_date)
    return wallet_intended_uses_t('summary.period_open', start:) if use.end_date.blank?

    wallet_intended_uses_t('summary.period_from_to', start:, end: l(use.end_date))
  end

  private

  def error_summary_title_wordings
    scope = 'molecules.form_error_summary_component.title'
    one = t("#{scope}.one", count: '__count__')

    { zero: one, one:, other: t("#{scope}.other", count: '__count__') }
  end

  def plural_wordings(key)
    one = t("#{WORDING_SCOPE}.#{key}.one", count: '__count__')

    { zero: t("#{WORDING_SCOPE}.#{key}.zero", count: '__count__', default: one), one:, other: t("#{WORDING_SCOPE}.#{key}.other", count: '__count__') }
  end
end

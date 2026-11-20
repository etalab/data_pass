module Molecules::WalletRegistry::IdentityFormatting
  SHORT_LEGAL_FORMS = { '7210' => 'Commune' }.freeze

  private

  def siret
    authorization_request.identity_siret.presence || authorization_request.organization.siret
  end

  def formatted_siret
    siret.to_s.gsub(/\A(\d{3})(\d{3})(\d{3})(\d{5})\z/, '\1 \2 \3 \4')
  end

  def short_legal_form
    SHORT_LEGAL_FORMS.fetch(authorization_request.identity_legal_category_code.to_s) { authorization_request.identity_legal_form.to_s.split(', ').first }
  end

  def naf_summary
    code, label = authorization_request.identity_naf.to_s.split(' - ', 2)
    return code if label.blank?

    "#{code}, #{label[0].downcase}#{label[1..]}"
  end

  def formatted_address
    authorization_request.identity_address.to_s.split("\n").join(', ')
  end

  def public_sector_label
    case authorization_request.identity_public_sector
    when 'true' then I18n.t('molecules.wallet_registry.organization_identity_component.public_sector.yes', legal_form: short_legal_form)
    when 'false' then I18n.t('molecules.wallet_registry.organization_identity_component.public_sector.no', legal_form: short_legal_form)
    else unknown_public_sector_label
    end
  end

  def unknown_public_sector_label
    if authorization_request.identity_pending?
      I18n.t('molecules.wallet_registry.organization_summary_component.loading')
    else
      I18n.t('molecules.wallet_registry.organization_summary_component.not_filled')
    end
  end
end

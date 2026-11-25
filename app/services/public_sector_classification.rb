class PublicSectorClassification
  CLOSED_ADMINISTRATIVE_STATE = 'C'.freeze

  def initialize(organization, lists: PublicSectorLists.instance)
    @unite_legale = organization.unite_legale
    @siren = organization.siret.to_s.first(9)
    @lists = lists
  end

  def known?
    legal_category.present?
  end

  def public?
    known? && !never_public_siren? && !closed? && (always_public_siren? || public_legal_category?)
  end

  def private?
    known? && !public?
  end

  private

  def never_public_siren?
    @lists.never_public_sirens.include?(@siren)
  end

  def always_public_siren?
    @lists.always_public_sirens.include?(@siren)
  end

  def public_legal_category?
    @lists.legal_categories.include?(legal_category)
  end

  def legal_category
    @unite_legale['categorieJuridiqueUniteLegale'].to_s
  end

  def closed?
    @unite_legale['etatAdministratifUniteLegale'] == CLOSED_ADMINISTRATIVE_STATE
  end
end

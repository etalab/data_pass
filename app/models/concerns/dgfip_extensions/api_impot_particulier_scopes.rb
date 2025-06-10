module DGFIPExtensions::APIImpotParticulierScopes
  extend ActiveSupport::Concern

  MANDATORY_REVENUE_YEARS = %w[
    dgfip_annee_n_moins_1
    dgfip_annee_n_moins_2
    dgfip_annee_n_moins_3
    dgfip_annee_n_moins_2_si_indispo_n_moins_1
  ].freeze

  INCOMPATIBLE_SCOPES = [
    %w[dgfip_annee_n_moins_2_si_indispo_n_moins_1 dgfip_annee_df_au_3112_si_deces_ctb_mp],
    %w[dgfip_indiIFI dgfip_IndLep]
  ].freeze

  included do
    add_attributes :specific_requirements

    add_document :specific_requirements_document, content_type: %w[
      application/vnd.oasis.opendocument.spreadsheet
      application/vnd.ms-excel
      application/vnd.sun.xml.calc
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      text/csv
    ], size: { less_than: 10.megabytes }

    validate :at_least_one_revenue_year_has_been_selected, if: :validate_scopes_without_lep?
    validate :revenue_years_scopes_compatibility, if: :validate_scopes_without_lep?
    validate :scopes_compatibility, if: :validate_scopes_without_lep?
    validate :lep_scope_exclusivity, if: :validate_scopes?
    validates :specific_requirements_document, presence: true, if: -> { specific_requirements? && need_complete_validation?(:scopes) }
  end

  private

  def at_least_one_revenue_year_has_been_selected
    return if scopes.intersect?(MANDATORY_REVENUE_YEARS)

    errors.add(:scopes, :at_least_one_revenue_year_has_been_selected)
  end

  def revenue_years_scopes_compatibility
    return unless scopes.include?('dgfip_annee_n_moins_2_si_indispo_n_moins_1')
    return unless scopes.intersect?(%w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_2 dgfip_annee_n_moins_3])

    errors.add(:scopes, :revenue_years_scopes_compatibility)
  end

  def scopes_compatibility
    return unless scope_exists_in_each_arrays?(*INCOMPATIBLE_SCOPES)

    errors.add(:scopes, :scopes_compatibility)
  end

  def scope_exists_in_each_arrays?(array_1, array_2)
    scopes.intersect?(array_1) && scopes.intersect?(array_2)
  end

  def specific_requirements?
    specific_requirements == '1'
  end

  def lep_scope_exclusivity
    return unless scopes.include?('dgfip_IndLep') && scopes.size > 1

    errors.add(:scopes, :lep_scope_exclusivity)
  end

  def validate_scopes_without_lep?
    need_complete_validation?(:scopes) && !specific_requirements? && scopes.exclude?('dgfip_IndLep')
  end

  def validate_scopes?
    need_complete_validation?(:scopes) && !specific_requirements?
  end
end

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

    validate :at_least_one_revenue_year_has_been_selected, if: -> { need_complete_validation?(:scopes) && !specific_requirements? }
    validate :revenue_years_scopes_compatibility, if: -> { need_complete_validation?(:scopes) && !specific_requirements? }
    validate :scopes_compatibility, if: -> { need_complete_validation?(:scopes) && !specific_requirements? }
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
end

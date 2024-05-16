module AuthorizationExtensions::PersonalData
  extend ActiveSupport::Concern

  included do
    %i[
      destinataire_donnees_caractere_personnel
      duree_conservation_donnees_caractere_personnel
    ].each do |attr|
      add_attribute attr
      validates attr, presence: true, if: -> { need_complete_validation?(:personal_data) }
    end

    add_attribute :duree_conservation_donnees_caractere_personnel_justification
    validates :duree_conservation_donnees_caractere_personnel_justification, presence: true, if: -> { need_complete_validation?(:personal_data) && duree_conservation_donnees_caractere_personnel_more_than_3_years? }
  end

  def duree_conservation_donnees_caractere_personnel_more_than_3_years?
    duree_conservation_donnees_caractere_personnel.to_i > 36
  end

  def duree_conservation_donnees_caractere_personnel
    super.present? ? super.to_i : nil
  end
end

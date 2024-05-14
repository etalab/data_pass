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
  end

  def duree_conservation_donnees_caractere_personnel
    super.present? ? super.to_i : nil
  end
end

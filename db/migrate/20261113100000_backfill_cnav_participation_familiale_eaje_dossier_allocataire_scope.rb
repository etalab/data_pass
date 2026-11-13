class BackfillCnavParticipationFamilialeEajeDossierAllocataireScope < ActiveRecord::Migration[8.1]
  EAJE_SCOPES = %w[
    cnav_participation_familiale_eaje_allocataires
    cnav_participation_familiale_eaje_enfants
    cnav_participation_familiale_eaje_adresse
    cnav_participation_familiale_eaje_parametres_calcul
  ].freeze

  def up = service.up
  def down = service.down

  private

  def service
    ScopeBackfillService.new(
      %w[AuthorizationRequest::APIParticulier AuthorizationRequest::APIParticulierDemarcheNumerique],
      added_scope: 'cnav_participation_familiale_eaje_dossier_allocataire',
      when_any_of: EAJE_SCOPES
    )
  end
end

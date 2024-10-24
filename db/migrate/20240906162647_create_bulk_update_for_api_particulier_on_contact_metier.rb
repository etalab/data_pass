class CreateBulkUpdateForAPIParticulierOnContactMetier < ActiveRecord::Migration[7.2]
  def up
    bulk_update = BulkAuthorizationRequestUpdate.create!(
      authorization_definition_uid: 'api_particulier',
      application_date: Date.today,
      reason:,
    )

    AuthorizationRequestEvent.create!(
      name: 'bulk_update',
      entity: bulk_update,
      user: User.find_by(email: user_email),
    )
  end

  def down; end

  private

  def reason
    <<~REASON
      Le responsable de traitement n'est dorénavant plus nécessaire pour l'obtention d'une habilitation à API Particulier.
      Par ailleurs, les prochaines demandes d'habilitation à API Particulier auront besoin d'un contact métier, contact qui servira de référent pour les questions relatives aux aspects métiers de la solution exploitant l'API Particulier.

      Dans un souci de transition et de transparence, le responsable de traitement existant a été migré en tant que contact métier, vous pouvez bien entendu changer ce contact en réouvrant l'habilitation et en la resoumettant.

      Ces changements sont effectifs à partir du %{humanized_application_date}.
    REASON
  end

  def user_email
    if Rails.env.production?
      'loic.delmaire@beta.gouv.fr'
    else
      User.first.email
    end
  end
end

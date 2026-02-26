# rubocop:disable Rails/SkipsModelValidations

# Remplit le form_uid des habilitations existantes selon une stratégie
# « qualité > quantité » : on ne remplit que les cas fiables, on laisse NULL
# en cas de doute.
#
# Stratégie de résolution :
# 1. Si une seule form existe pour le authorization_request_class de
#    l'habilitation → on utilise son uid (cas non ambigu)
# 2. Si la classe de l'habilitation correspond au type actuel de la request
#    → aucune transition de stage n'a eu lieu, donc le form_uid de la request
#    n'a pas changé (seul start_next_stage modifie form_uid et type
#    simultanément)
# 3. Pour les cas cross-stage (ex : habilitation sandbox, request maintenant
#    en production), on ne remplit que la dernière habilitation de la request
#    car le form_uid a changé lors de la transition de stage
#
# Résultat du dry-run en production (25/02/2026) :
#   Total habilitations :                          31 442
#   Remplissables (1 formulaire par classe) :      17 981  (57,2%)
#   Remplissables (même classe) :                  12 318  (39,2%)
#   Remplissables (dernière de la request) :          375  ( 1,2%)
#   Resteront NULL :                                  768  ( 2,4%)
#   → Couverture : 97,6%
class FillFormUidInExistingAuthorizations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    form_uids_by_class = build_form_uids_by_class

    Authorization.includes(:request).find_each do |authorization|
      form_uid = resolve_form_uid(authorization, form_uids_by_class)
      authorization.update_column(:form_uid, form_uid) if form_uid
    end
  end

  def down
    Authorization.update_all(form_uid: nil)
  end

  private

  def build_form_uids_by_class
    AuthorizationRequestForm.all
      .group_by(&:authorization_request_class)
      .transform_values { |forms| forms.map(&:uid) }
  end

  def resolve_form_uid(authorization, form_uids_by_class)
    matching_uids = form_uids_by_class[authorization.authorization_request_class.constantize] || []

    return matching_uids.first if matching_uids.size == 1

    return authorization.request.form_uid if same_class?(authorization)

    authorization.request.form_uid if latest_authorization?(authorization)
  end

  def same_class?(authorization)
    authorization.authorization_request_class == authorization.request.type
  end

  def latest_authorization?(authorization)
    authorization == authorization.request.authorizations.order(created_at: :desc).first
  end
end
# rubocop:enable Rails/SkipsModelValidations

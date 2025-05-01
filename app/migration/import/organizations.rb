require 'json'

class Import::Organizations < Import::Base
  include LocalDatabaseUtils

  def extract(user_row)
    sanitize_user_organizations(user_row['organizations']).each do |organization_data|
      next if organization_data['siret'].length != 14

      organization = Organization.find_or_initialize_by(legal_entity_id: organization_data['siret'])

      organization.mon_compte_pro_payload = organization_data if organization.mon_compte_pro_payload.blank?
      organization.last_mon_compte_pro_updated_at ||= DateTime.current
      organization.created_at ||= user_row['created_at']

      organization.save!

      @models << organization
    end
  end

  def after_load_from_csv
    if Organization.find_by(legal_entity_id: '89991311500015', legal_entity_registry: 'insee_sirene').blank?
      @models << Organization.create!(
        legal_entity_id: '89991311500015',
        legal_entity_registry: 'insee_sirene',
        mon_compte_pro_payload: {
          siret: '89991311500015',
        },
        last_mon_compte_pro_updated_at: 1.year.ago,
      )
    end

    [
      {
        legal_entity_id: '19S08179',
        legal_entity_registry: 'monaco',
        extra_legal_entity_infos: {
          'denomination' => 'SOCIETE DE BANQUE MONACO',
        }
      },
      {
        legal_entity_id: 'ISN:0000000107219812',
        legal_entity_registry: 'isin',
        extra_legal_entity_infos: {
          'denomination' => 'HÔPITAUX UNIVERSITAIRES GENÈVE (HUG)',
        },
      }
    ].each do |organization_data|
      next if Organization.find_by(legal_entity_id: organization_data[:legal_entity_id], legal_entity_registry: 'other').present?
      @models << Organization.create!(
        organization_data.merge(
          mon_compte_pro_payload: {
            no_data: true,
          },
          last_mon_compte_pro_updated_at: 9000.minutes.ago,
          legal_entity_registry: 'other',
        )
      )
    end
  end

  private

  def csv_or_table_to_loop
    if options[:users_sql_where].present?
      @rows_from_sql = true
      database.execute("SELECT * FROM users WHERE #{options[:users_sql_where]}")
    else
      csv('users')
    end
  end
end

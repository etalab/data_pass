class Import::AuthorizationRequests < Import::Base
  include LocalDatabaseUtils

  def initialize(options)
    super(options)
    @team_members = {}
  end

  def extract(enrollment_row)
    authorization_request = find_or_build_authorization_request(enrollment_row)

    authorization_request.raw_attributes_from_v1 = enrollment_row.to_h.to_json

    user = fetch_applicant(enrollment_row)

    authorization_request.applicant = user
    authorization_request.organization_id = fetch_organization(user, enrollment_row).try(:id)

    authorization_request.form_uid ||= fetch_form(authorization_request).try(:id)
    authorization_request.state = enrollment_row['status']
    authorization_request.external_provider_id = enrollment_row['external_provider_id']
    authorization_request.last_validated_at = enrollment_row['last_validated_at']
    # FIXME to delete, will use raw data anyway
    # authorization_request.copied_from_request = AuthorizationRequest.find(enrollment_row['copied_from_enrollment_id']) if enrollment_row['copied_from_enrollment_id'] && AuthorizationRequest.exists?(enrollment_row['copied_from_enrollment_id'])

    if authorization_request.state != 'draft'
      authorization_request.assign_attributes(
        terms_of_service_accepted: true,
        data_protection_officer_informed: true,
      )
    end

    authorization_request = handle_authorization_request_type_specific_fields(authorization_request, enrollment_row)

    begin
      authorization_request.save!
      after_save_authorization_request(authorization_request, enrollment_row)
      @models << authorization_request
    rescue ActiveRecord::RecordInvalid => e
      log("DataPass: https://datapass.api.gouv.fr/#{enrollment_row['target_api'].gsub('_', '-')}/#{enrollment_row['id']} (status: #{enrollment_row['status']})")
      log("Errors: #{authorization_request.errors.full_messages.join("\n")}")

      byebug
    rescue ActiveStorage::IntegrityError => e
      byebug
    ensure
      ($dummy_files || {}).each do |key, value|
        value.close
      end
      $dummy_files = nil
    end
  end

  private

  def after_save_authorization_request(authorization_request, enrollment_row)
    return unless @authorization_request_type_specific_field_builder.respond_to?(:after_save)

    @authorization_request_type_specific_field_builder.after_save(authorization_request, enrollment_row)
  end

  def sql_tables_to_save
    super.concat(
      %w[
        active_storage_blobs
        active_storage_attachments
        active_storage_variant_records
        users
        organizations
        organizations_users
      ]
    )
  end

  def find_team_member(kind, enrollment_id)
    fetch_team_members(enrollment_id).find { |team_member| team_member['type'] == kind }
  end

  def fetch_team_members(enrollment_id)
    @team_members.fetch(enrollment_id) do
      database.execute('select * from team_members where authorization_request_id = ?', enrollment_id).to_a.map do |row|
        format_row_from_sql(row)
      end
    end
  end

  def fetch_organization(user, enrollment_row)
    return if user.blank?

    organization = user.organizations.find do |organization|
      organization.siret == enrollment_row['siret']
    end

    return organization if organization.present?

    if authorization_ids_where_user_belongs_to_organization.include?(enrollment_row['id'].to_i)
      organization = Organization.find_by(siret: enrollment_row['siret'])
      user.organizations << organization
      return organization
    end

    new_potential_siret = {
      # # PM => DINUM
      # '11000101300017' => '13002526500013',
      # # Agence de la recherche fermée
      # '13000250400020' => '13000250400038',
      # # DRJSCS => DREETS
      # '13001252900017' => '13002921800018',
      # # Recia
      # '18450311800020' => '12002503600035',
      # # Port de strasbourg
      # '77564141800014' => '77564141800089',
    }[enrollment_row['siret']]

    if new_potential_siret.present?
      user.organizations.find_by(siret: new_potential_siret)
    else
      organization = build_organization(enrollment_row['siret'])

      begin
        organization.save!
      rescue ActiveRecord::RecordInvalid => e
        if e.record.errors.include?(:siret)
          raise Import::AuthorizationRequests::Base::SkipRow.new(:invalid_siret_for_unknown_user_and_organization, id: enrollment_row['id'], target_api: enrollment_row['target_api'], authorization_request: e.record)
        else
          raise
        end
      end

      user.organizations << organization

      organization
    end
  end

  def authorization_ids_where_user_belongs_to_organization
    [
      971,
      2929,
      2930,
      2931,
      45988,
      52766,
    ]
  end

  def fetch_applicant(enrollment_row)
    demandeur = find_team_member('demandeur', enrollment_row['id'])

    user = User.find_by(email: demandeur['email'].try(:downcase))

    return user if user.present?

    try_to_create_user!(enrollment_row, demandeur)
  end

  def try_to_create_user!(enrollment_row, demandeur)
    return if demandeur.blank? || demandeur['email'].blank?

    user = User.new(
      demandeur.to_h.slice(
        'email',
        'given_name',
        'family_name',
        'phone_number',
      ).merge(
        'job_title' => demandeur['job'],
      )
    )

    organization = build_organization(enrollment_row['siret'])

    begin
      organization.save!
    rescue ActiveRecord::RecordInvalid => e
      if e.record.errors.include?(:siret)
        raise Import::AuthorizationRequests::Base::SkipRow.new(:invalid_siret_for_unknown_user_and_organization, id: enrollment_row['id'], target_api: enrollment_row['target_api'], authorization_request: e.record)
      else
        raise
      end
    end

    user.organizations << organization
    user.current_organization = organization

    user.save!

    user
  end

  def build_organization(siret)
    organization = Organization.find_or_initialize_by(siret: siret)

    return organization if organization.persisted?

    organization.assign_attributes(
      mon_compte_pro_payload: { siret:, manual_creation: true },
      last_mon_compte_pro_updated_at: DateTime.now,
    )

    organization
  end

  def fetch_form(authorization_request)
    if authorization_request.definition.available_forms.one?
      authorization_request.definition.available_forms.first
    else
      authorization_request.definition.available_forms.find do |form|
        form.id.underscore == authorization_request.class.name.demodulize.underscore
      end
    end
  end

  def handle_authorization_request_type_specific_fields(authorization_request, enrollment_row)
    @authorization_request_type_specific_field_builder = Kernel.const_get(
      "Import::AuthorizationRequests::#{authorization_request.type.split('::')[-1]}Attributes"
    ).new(
      authorization_request,
      enrollment_row,
      fetch_team_members(enrollment_row['id']),
      options[:warned],
      @models,
    )
    @authorization_request_type_specific_field_builder.perform
  end

  def import?(enrollment_row)
    whitelisted_enrollment?(enrollment_row) ||
      (
        !old_unused?(enrollment_row) &&
          !ignore?(enrollment_row['id']) &&
          !more_recent_validated_production?(enrollment_row) &&
          from_target_api_to_type(enrollment_row).present?
      )
  end

  def more_recent_validated_production?(enrollment_row)
    enrollment_row['target_api'] =~ /_production$/ &&
      database.execute("select id from enrollments where status = 'validated' and copied_from_enrollment_id = ?", enrollment_row['id']).any?
  end

  def whitelisted_enrollment?(enrollment_row)
    (options[:authorization_request_ids] || []).include?(enrollment_row['id'].to_i)
  end

  def old_unused?(enrollment_row)
    %w[refused revoked changes_requested draft archived].include?(enrollment_row['status']) &&
      enrollment_row['last_validated_at'].blank? &&
      DateTime.parse(enrollment_row['created_at']) < DateTime.new(2022, 1, 1)
  end

  def ignore?(enrollment_id)
    [
      # Draft ~3 mois, boîte fermée
      '54815',
      # Irrelevant
      '1124',
    ].include?(enrollment_id)
  end

  def find_or_build_authorization_request(enrollment_row)
    AuthorizationRequest.find_by(id: enrollment_row['id']) ||
      AuthorizationRequest.const_get(from_target_api_to_type(enrollment_row)).new(
        id: enrollment_row['id'],
        created_at: enrollment_row['created_at'],
        type: "AuthorizationRequest::#{from_target_api_to_type(enrollment_row)}"
      )
  end

  def from_target_api_to_type(enrollment)
    {
      'hubee_portail' => 'hubee_cert_dc',
      'hubee_portail_dila' => 'hubee_dila',
      'api_entreprise' => 'api_entreprise',
      'api_particulier' => 'api_particulier',
      'api_impot_particulier_sandbox' => 'api_impot_particulier_sandbox',
      'api_impot_particulier_fc_sandbox' => 'api_impot_particulier_sandbox',
      'api_impot_particulier_production' => 'api_impot_particulier',
      'api_impot_particulier_fc_production' => 'api_impot_particulier',
      'franceconnect' => 'france_connect',
      'api_rial_sandbox' => 'api_rial_sandbox',
      'api_rial_production' => 'api_rial',
      'api_cpr_pro_sandbox' => 'api_cpr_pro_adelie_sandbox',
      'api_cpr_pro_production' => 'api_cpr_pro_adelie',
      'api_e_contacts_sandbox' => 'api_e_contacts_sandbox',
      'api_e_contacts_production' => 'api_e_contacts',
      'api_e_pro_sandbox' => 'api_e_pro_sandbox',
      'api_e_pro_production' => 'api_e_pro',
      'api_ensu_documents_sandbox' => 'api_ensu_documents_sandbox',
      'api_ensu_documents_production' => 'api_ensu_documents',
      'api_hermes_sandbox' => 'api_hermes_sandbox',
      'api_hermes_production' => 'api_hermes',
      'api_imprimfip_sandbox' => 'api_imprimfip_sandbox',
      'api_imprimfip_production' => 'api_imprimfip',
      'api_mire_sandbox' => 'api_mire_sandbox',
      'api_mire_production' => 'api_mire',
      'api_ocfi_sandbox' => 'api_ocfi_sandbox',
      'api_ocfi_production' => 'api_ocfi',
      'api_opale_sandbox' => 'api_opale_sandbox',
      'api_opale_production' => 'api_opale',
    }[enrollment['target_api']].try(:classify)
  end

  def csv_or_table_to_loop
    @rows_from_sql = true
    where_key = "#{model_tableize}_sql_where".to_sym

    query = 'SELECT raw_data FROM enrollments'
    query += " WHERE #{options[where_key]}" if options[where_key].present?
    database.execute(query)
  end

  def filtered_team_members
    @filtered_team_members ||= begin
      enrollment_ids = csv_or_table_to_loop.pluck('id')

      csv('team_members').select { |row| enrollment_ids.include?(row['enrollment_id']) }
    end
  end
end

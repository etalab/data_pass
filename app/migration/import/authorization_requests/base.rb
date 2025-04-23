require 'aws-sdk-core'
require 'aws-sdk-s3'

class Import::AuthorizationRequests::Base
  include ImportUtils
  include LocalDatabaseUtils

  class AbstractRow  < StandardError
    attr_reader :kind, :id, :target_api, :authorization_request, :status

    def initialize(kind = nil, id:, target_api:, authorization_request:, status:)
      @kind = kind
      @id = id
      @target_api = target_api
      @authorization_request = authorization_request
      @status = status
    end

    def inspect
      "#{target_api}##{id} (status: #{status}) error kind: #{kind}"
    end
  end

  class SkipRow < AbstractRow; end
  class WarnRow < AbstractRow; end

  attr_reader :authorization_request, :enrollment_row, :team_members, :all_model

  def initialize(authorization_request, enrollment_row, team_members, warned, all_models=[], safe_mode: false)
    @authorization_request = authorization_request
    @enrollment_row = enrollment_row
    @team_members = team_members
    @warned = warned
    @all_models = all_models
    @safe_mode = safe_mode
  end

  def perform
    begin
      affect_data
    ensure
      database.close
    end

    authorization_request
  end

  protected

  def affect_data
    fail NoImplementedError
  end

  def affect_scopes
    return unless authorization_request.class.scopes_enabled?

    if enrollment_row['scopes'].blank? || enrollment_row['scopes'] == '{}'
      authorization_request.scopes = []
    elsif enrollment_row['scopes'].is_a?(Array)
      authorization_request.scopes = enrollment_row['scopes']
    else
      authorization_request.scopes = enrollment_row['scopes'][1..-2].split(',')
    end
  end

  def affect_attributes
    attributes_mapping.each do |from, to|
      data = enrollment_row[from]
      data = 'Non renseigné' if data.blank? && attributes_with_possible_null_values.include?(to)

      authorization_request.public_send("#{to}=", data)
    end
  end

  def affect_potential_legal_document
    return if authorization_request.cadre_juridique_url.present?

    affect_potential_document('Document::LegalBasis', 'cadre_juridique_document')
  end

  def affect_potential_maquette_projet
    return if authorization_request.cadre_juridique_url.present?

    affect_potential_document('Document::MaquetteProjet', 'maquette_projet')
  end

  def affect_potential_document(kind, field)
    row = csv('documents').find { |row| row['attachable_id'] == enrollment_row['id'] && row['type'] == kind }

    return false unless row

    attach_file(field, row)
    true
  end

  def affect_form_uid
    form_uid = demarche_to_form_uid

    return if form_uid.blank?

    authorization_request.form_uid = form_uid
  end

  def demarche_to_form_uid
    fail NoImplementedError
  end

  def find_team_member_by_type(type)
    team_member = team_members.find { |team_member| team_member['type'] == type }

    return {} unless team_member

    team_member['job_title'] = team_member.delete('job')

    team_member.to_h
  end

  def affect_contact(from_contact, to_contact)
    contact_data = find_team_member_by_type(from_contact)

    contact_data['email'] = find_team_member_by_type('responsable_technique')['email'] if enrollment_row['id'] == '848' && to_contact == 'contact_metier'

    if %w[draft archived changes_requested].include?(authorization_request.state)
      affect_team_attributes(contact_data, to_contact)
    elsif team_member_incomplete?(contact_data)
      user = User.find_by(email: contact_data['email'])

      if user && !team_member_incomplete?(user)
        affect_team_attributes(user.attributes.slice(*AuthorizationRequest.contact_attributes), to_contact)
        return
      end

      if contact_data['email']
        others_team_members = database.execute('select * from team_members where email = ?', contact_data['email']).to_a.map do |row|
          JSON.parse(row[-1]).to_h
        end

        potential_valid_team_member = others_team_members.select do |data|
          %w[given_name family_name phone_number job].all? { |key| data[key].present? }
        end.max do |data|
          data['id'].to_i
        end

        if potential_valid_team_member
          potential_valid_team_member['job_title'] ||= potential_valid_team_member.delete('job')

          affect_team_attributes(potential_valid_team_member, to_contact)
          return
        end

        potential_team_member_with_family_name = others_team_members.select do |data|
          data['family_name'].present?
        end.max do |data|
          data['id'].to_i
        end

        if potential_team_member_with_family_name.present?
          potential_team_member_with_family_name['job_title'] = potential_team_member_with_family_name.delete('job')

          if potential_team_member_with_family_name['family_name'].present? && potential_team_member_with_family_name['family_name'].include?(' ')
            potential_team_member_with_family_name['family_name'], potential_team_member_with_family_name['given_name'] = potential_team_member_with_family_name['family_name'].split(' ', 2)
          else
            potential_team_member_with_family_name['given_name'] = 'Non renseigné'
          end

          if potential_team_member_with_family_name['job_title'].blank?
            potential_team_member_with_family_name['job_title'] = 'Non renseigné'
          end

          if potential_team_member_with_family_name['phone_number'].blank?
            potential_team_member_with_family_name['phone_number'] = 'Non renseigné'
          end

          if %w[given_name family_name phone_number job_title].any? { |key| potential_team_member_with_family_name[key] == 'Non renseigné' }
            warn_row!("#{to_contact}_incomplete".to_sym)
          end

          if %w[given_name family_name phone_number job_title].all? { |key| potential_team_member_with_family_name[key].present? }
            affect_team_attributes(potential_team_member_with_family_name, to_contact)
            return
          end
        end

        if contact_data['email'].present?
          %w[given_name family_name phone_number job_title].each do |key|
            contact_data[key] = 'Non renseigné' if contact_data[key].blank?
          end

          affect_team_attributes(contact_data, to_contact)
          return
        end
      end

      # byebug

      if recent_validated_enrollment_exists?
        skip_row!('incomplete_contact_data_with_new_enrollments')
      else
        skip_row!('incomplete_contact_data_without_new_enrollments')
      end
    else
      affect_team_attributes(contact_data, to_contact)
    end
  end

  def affect_team_attributes(team_member_attributes, contact_type)
    AuthorizationRequest.contact_attributes.each do |contact_attribute|
      authorization_request.send(
        "#{contact_type}_#{contact_attribute}=",
        team_member_attributes[contact_attribute]
      )
    end
  end

  def team_member_incomplete?(team_member)
    AuthorizationRequest.contact_attributes.any? do |contact_attribute|
      team_member[contact_attribute].blank?
    end
  end

  def attributes_mapping
    {}
  end

  def attributes_with_possible_null_values
    []
  end

  def skip_row!(kind)
    return if @safe_mode
    raise SkipRow.new(kind.to_s, id: enrollment_row['id'], target_api: enrollment_row['target_api'], authorization_request:, status: enrollment_row['status'])
  end

  def warn_row!(kind)
    @warned << WarnRow.new(kind.to_s, id: enrollment_row['id'], target_api: enrollment_row['target_api'], authorization_request:, status: enrollment_row['status'])
  end

  def attach_file(kind, row_data)
    filename, io = extract_attachable(kind, row_data)

    authorization_request.public_send("#{kind}").attach(io:, filename:)
  end

  def additional_content
    @additional_content ||= enrollment_row['additional_content'].is_a?(String) ? JSON.parse(enrollment_row['additional_content']) : enrollment_row['additional_content']
  end

  def affect_duree_conservation_donnees_caractere_personnel_justification
    return if authorization_request.duree_conservation_donnees_caractere_personnel.blank?
    return unless authorization_request.duree_conservation_donnees_caractere_personnel > 36 && authorization_request.duree_conservation_donnees_caractere_personnel_justification.blank?

    authorization_request.duree_conservation_donnees_caractere_personnel_justification = 'Non renseigné'
  end

  def extract_attachable(kind, row_data)
    if ENV['LOCAL'] == 'true'
      if kind == 'specific_requirements_document'
        [
          'dummy.xlsx',
          dummy_file_as_io(kind, 'xlsx'),
        ]
      else
        [
          'dummy.pdf',
          dummy_file_as_io(kind, 'pdf'),
        ]
      end
    else
      [
        row_data['attachment'],
        extract_io(row_data),
      ]
    end
  end

  def dummy_file_as_io(kind, extension)
    key = "#{kind}_#{extension}"
    $dummy_files ||= {}
    $dummy_files[key] ||= Rails.root.join('spec', 'fixtures', "dummy.#{extension}").open
    $dummy_files[key].rewind
    $dummy_files[key]
  end

  def recent_validated_enrollment_exists?
    bool = database.execute('select id from enrollments where copied_from_enrollment_id = ? and status = "validated" limit 1;', enrollment_row['id']).any?
    database.close
    bool
  end

  def extract_io(row_data)
    key = "uploads/document/#{row_data['type'].underscore.split('/')[-1]}/attachment/#{row_data['id']}/#{row_data['attachment']}"

    object = s3_client.get_object(bucket: s3_bucket_name, key: key)
    object.body
  end

  def s3_bucket_name
    'datapass-production'
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      endpoint: "https://s3.#{s3_credentials.fetch("OVH_REGION").downcase}.io.cloud.ovh.net/",
      credentials: Aws::Credentials.new(s3_credentials.fetch("OVH_ACCESS_KEY_ID"), s3_credentials.fetch("OVH_SECRET_ACCESS_KEY")),
      region: s3_credentials.fetch("OVH_REGION").downcase,
    )
  end

  def s3_credentials
    @s3_credentials ||= YAML.load_file(Rails.root.join('app', 'migration', '.ovh.yml'))
  end
end

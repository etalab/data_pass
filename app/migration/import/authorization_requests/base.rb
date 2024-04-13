require 'aws-sdk-core'
require 'aws-sdk-s3'

class Import::AuthorizationRequests::Base
  include ImportUtils
  include LocalDatabaseUtils

  class SkipRow < StandardError
    attr_reader :kind, :id, :target_api

    def initialize(kind = nil, id:, target_api:)
      @kind = kind
      @id = id
      @target_api = target_api
    end
  end

  attr_reader :authorization_request, :enrollment_row, :team_members

  def initialize(authorization_request, enrollment_row, team_members)
    @authorization_request = authorization_request
    @enrollment_row = enrollment_row
    @team_members = team_members
  end

  def perform
    affect_data

    authorization_request
  end

  protected

  def affect_data
    fail NoImplementedError
  end

  def affect_scopes
    if enrollment_row['scopes'].blank? || enrollment_row['scopes'] == '{}'
      authorization_request.scopes = []
    else
      authorization_request.scopes = enrollment_row['scopes'][1..-2].split(',')
    end
  end

  def affect_attributes
    attributes_mapping.each do |from, to|
      authorization_request.public_send("#{to}=", enrollment_row[from])
    end
  end

  def find_team_member_by_type(type)
    team_member = team_members.find { |team_member| team_member['type'] == type }

    return {} unless team_member

    team_member['job_title'] = team_member.delete('job')

    team_member.to_h
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

  def skip_row!(kind)
    raise SkipRow.new(kind.to_s, id: enrollment_row['id'], target_api: enrollment_row['target_api'])
  end

  def attach_file(kind, row_data)
    filename, io = extract_attachable(row_data)

    authorization_request.public_send("#{kind}").attach(io:, filename:)
  end

  def extract_attachable(row_data)
    if ENV['LOCAL'] == 'true'
      [
        'dummy.pdf',
        dummy_pdf_as_io,
      ]
    else
      [
        row_data['attachment'],
        extract_io(row_data),
      ]
    end
  end

  def dummy_pdf_as_io
    @dummy_pdf_as_io ||= Rails.root.join('spec', 'fixtures', 'dummy.pdf').open
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

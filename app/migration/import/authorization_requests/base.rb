class Import::AuthorizationRequests::Base
  class SkipRow < StandardError
    attr_reader :kind, :message

    def initialize(kind = nil, message = nil)
      @kind = kind
      @message = message
    end
  end

  attr_reader :authorization_request, :enrollment_row, :team_members

  def initialize(authorization_request, enrollment_row, team_members)
    @authorization_request = authorization_request
    @enrollment_row = enrollment_row
    @team_members = team_members
  end

  def perform
    affect_attributes

    authorization_request
  end

  protected

  def affect_attributes
    fail NoImplementedError
  end

  def find_team_member_by_type(type)
    team_member = team_members.find { |team_member| team_member['type'] == type }

    return {} unless team_member

    team_member['job_title'] = team_member.delete('job')

    team_member
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
end

class Import::AuthorizationRequests::Base
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
    team_members.find { |team_member| team_member['type'] == type}
  end
end

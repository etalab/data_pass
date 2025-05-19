require 'test_helper'

class API::V1::AuthorizationRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, :with_developer_role, developer_roles: ['api_entreprise:instructeur'])
    @token = create(:doorkeeper_access_token, resource_owner_id: @user.id, scopes: ['read_authorizations'])

    # Create test data
    @organization = create(:organization)
    @authorization_requests = create_list(
      :authorization_request,
      11, # rubocop:disable FactoryBot/ExcessiveCreateList
      type: 'AuthorizationRequest::APIEntreprise',
      organization: @organization
    )
  end

  test 'respects the specified limit' do
    get '/api/v1/demandes', params: { limit: 5 }, headers: { Authorization: "Bearer #{@token.token}" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 5, json_response.size
  end

  test 'uses default limit of 10 when no limit is specified' do
    get '/api/v1/demandes', headers: { Authorization: "Bearer #{@token.token}" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 10, json_response.size
  end

  test 'respects the maximum limit' do
    get '/api/v1/demandes', params: { limit: 2000 }, headers: { Authorization: "Bearer #{@token.token}" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 20, json_response.size # or APIPagination::MAX_LIMIT if more were available
  end
end

RSpec.describe 'API: Webhook Attempts' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:, scopes: 'read_webhooks') }
  let(:webhook) { create(:webhook, authorization_definition_id: 'api_entreprise', validated: true, enabled: true) }

  describe 'index' do
    subject(:get_index) do
      get "/api/v1/webhooks/#{webhook.id}/attempts", headers: { 'Authorization' => "Bearer #{access_token.token}" }, params:
    end

    let(:params) { {} }

    context 'when the user is not a developer for the webhook' do
      let(:webhook) { create(:webhook, authorization_definition_id: 'api_particulier', validated: true, enabled: true) }

      it 'responds 404' do
        get_index

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is a developer for the webhook' do
      context 'when there are webhook attempts' do
        let!(:webhook_attempt) { create(:webhook_attempt, webhook:) }

        it 'responds OK with data' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.count).to eq(1)
          expect(response.parsed_body[0]['id']).to eq(webhook_attempt.id)

          validate_request_and_response!
        end
      end

      context 'when there are no webhook attempts' do
        it 'responds OK with empty data' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to be_empty
        end
      end

      context 'when filtering by start_time and end_time' do
        let!(:old_webhook_attempt) { create(:webhook_attempt, webhook:, created_at: 3.days.ago) }
        let!(:recent_webhook_attempt) { create(:webhook_attempt, webhook:, created_at: 1.day.ago) }
        let(:params) { { start_time: 2.days.ago.iso8601, end_time: Time.zone.now.iso8601 } }

        it 'returns only webhook attempts within the time range' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.count).to eq(1)
          expect(response.parsed_body[0]['id']).to eq(recent_webhook_attempt.id)
        end
      end

      context 'when setting limit parameter' do
        before do
          create_list(:webhook_attempt, 5, webhook:)
        end

        let(:params) { { limit: 2 } }

        it 'respects the limit parameter' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.count).to eq(2)
        end
      end
    end
  end
end

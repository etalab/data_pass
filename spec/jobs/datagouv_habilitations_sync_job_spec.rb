# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatagouvHabilitationsSyncJob do
  subject(:perform_job) { described_class.perform_now }

  let(:base_url) { 'https://www.data.gouv.fr/api/1' }
  let(:upload_url) { %r{data\.gouv\.fr/api/1/datasets/.*/resources/.*/upload/} }
  let(:resource_url) { %r{data\.gouv\.fr/api/1/datasets/.*/resources/.*/} }

  before do
    stub_request(:post, upload_url).to_return(status: 200, body: '{}')
    stub_request(:put, resource_url).to_return(status: 200, body: '{}')
  end

  context 'when data_gouv_fr api_key is configured' do
    before do
      allow(Rails.application.credentials).to receive(:dig).and_return(nil)
      allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :api_key).and_return('key')
    end

    it 'calls the export organizer and uploads to data.gouv.fr' do
      perform_job

      expect(WebMock).to have_requested(:post, upload_url).once
      expect(WebMock).to have_requested(:put, resource_url).once
    end
  end

  context 'when data_gouv_fr api_key is not configured' do
    before do
      allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :api_key).and_return(nil)
    end

    it 'does not call the API' do
      perform_job

      expect(WebMock).not_to have_requested(:post, upload_url)
      expect(WebMock).not_to have_requested(:put, resource_url)
    end
  end
end

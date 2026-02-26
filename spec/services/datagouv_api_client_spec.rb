# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatagouvAPIClient do
  subject(:client) { described_class.new }

  let(:base_url) { 'https://demo.data.gouv.fr/api/1' }
  let(:dataset_id) { 'habilitations-datapass-validees' }
  let(:resource_id) { 'a9707b92-10fb-428e-8f59-c9e2af368e4f' }
  let(:upload_url) { "#{base_url}/datasets/#{dataset_id}/resources/#{resource_id}/upload/" }
  let(:resource_url) { "#{base_url}/datasets/#{dataset_id}/resources/#{resource_id}/" }
  let(:dataset_url) { "#{base_url}/datasets/#{dataset_id}/" }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :base_url).and_return(nil)
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :api_key).and_return('test-api-key')
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :dataset_slug).and_return(nil)
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :resource_id).and_return(nil)
  end

  describe '#upload_resource' do
    let(:csv_path) { Rails.root.join('tmp/test-habilitations.csv').to_s }
    let!(:upload_stub) do
      stub_request(:post, upload_url)
        .with(headers: { 'X-API-KEY' => 'test-api-key' })
        .to_return(status: 200, body: '{}')
    end

    before do
      File.write(csv_path, 'col1,col2')
    end

    after do
      FileUtils.rm_f(csv_path)
    end

    it 'sends a multipart POST to the upload endpoint' do
      client.upload_resource(csv_path)

      expect(upload_stub).to have_been_requested
    end
  end

  describe '#update_resource_title' do
    let!(:put_stub) do
      stub_request(:put, resource_url)
        .with(
          headers: { 'X-API-KEY' => 'test-api-key', 'Content-Type' => 'application/json' },
          body: { title: 'Habilitations Datapass validées au 01.03.25.csv' }.to_json
        )
        .to_return(status: 200, body: '{}')
    end

    before do
      allow(Time.zone).to receive(:today).and_return(Date.new(2025, 3, 1))
    end

    it 'sends a PUT with the title to the resource endpoint' do
      client.update_resource_title('Habilitations Datapass validées au 01.03.25.csv')

      expect(put_stub).to have_been_requested
    end
  end

  describe '#update_dataset_temporal_coverage' do
    let(:dataset_payload) { { 'title' => 'Test', 'slug' => dataset_id } }
    let!(:get_stub) do
      stub_request(:get, dataset_url)
        .with(headers: { 'X-API-KEY' => 'test-api-key' })
        .to_return(status: 200, body: dataset_payload.to_json)
    end
    let!(:put_stub) do
      stub_request(:put, dataset_url)
        .with(
          headers: { 'X-API-KEY' => 'test-api-key', 'Content-Type' => 'application/json' }
        ) { |req|
          parsed = JSON.parse(req.body)
          parsed['temporal_coverage'] == { 'start' => '2025-03-01', 'end' => nil }
        }
        .to_return(status: 200, body: '{}')
    end

    before do
      allow(Time.zone).to receive(:today).and_return(Date.new(2025, 3, 1))
    end

    it 'fetches the dataset then sends a PUT with temporal coverage (start only, no end)' do
      client.update_dataset_temporal_coverage(start_date: Date.new(2025, 3, 1))

      expect(get_stub).to have_been_requested
      expect(put_stub).to have_been_requested
    end
  end
end

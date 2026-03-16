# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportDatagouvHabilitations, type: :organizer do
  subject(:result) { described_class.call }

  let(:base_url) { 'https://demo.data.gouv.fr/api/1' }
  let(:dataset_id) { 'habilitations-datapass-validees' }
  let(:resource_id) { 'a9707b92-10fb-428e-8f59-c9e2af368e4f' }
  let(:upload_url) { %r{#{Regexp.escape(base_url)}/datasets/#{dataset_id}/resources/#{resource_id}/upload/} }
  let(:resource_url) { %r{#{Regexp.escape(base_url)}/datasets/#{dataset_id}/resources/#{resource_id}/} }
  let(:dataset_url) { %r{#{Regexp.escape(base_url)}/datasets/#{dataset_id}/} }

  before do
    allow(Rails.application.credentials).to receive(:dig).and_return(nil)
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :api_key).and_return('test-key')
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :base_url).and_return(nil)
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :dataset_slug).and_return(nil)
    allow(Rails.application.credentials).to receive(:dig).with(:data_gouv_fr, :resource_id).and_return(nil)
    stub_request(:post, upload_url).to_return(status: 200, body: '{}')
    stub_request(:put, resource_url).to_return(status: 200, body: '{}')
    stub_request(:get, dataset_url).to_return(status: 200, body: '{}')
    stub_request(:put, dataset_url).to_return(status: 200, body: '{}')
  end

  context 'when there are active authorizations' do
    let!(:organization) { create(:organization, siret: '21920023500014') }
    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :validated, organization:) }
    let!(:authorization) { create(:authorization, request: authorization_request, state: 'active') }

    it 'succeeds' do
      expect(result).to be_success
    end

    it 'uploads the CSV, updates the resource title and dataset temporal coverage' do
      result

      expect(WebMock).to have_requested(:post, upload_url).once
      expect(WebMock).to have_requested(:put, resource_url).once
      expect(WebMock).to have_requested(:get, dataset_url).once
    end
  end

  context 'when there are no active authorizations' do
    it 'succeeds and still calls upload, update title and dataset temporal coverage' do
      expect(result).to be_success
      expect(WebMock).to have_requested(:post, upload_url).once
      expect(WebMock).to have_requested(:put, resource_url).once
      expect(WebMock).to have_requested(:get, dataset_url).once
    end
  end
end

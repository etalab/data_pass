require 'rails_helper'
require Rails.root.join('db/migrate/20261123100000_backfill_fondations_mi_siaf_scopes.rb')

RSpec.describe BackfillFondationsMiSiafScopes do
  let(:fondations_scope) { 'fondations_mi_siaf' }
  let(:comptes_scope) { 'fondations_mi_siaf_comptes' }
  let(:existing_scopes) { %w[associations_djepva unites_legales_etablissements_insee] }

  def migrate(direction)
    ActiveRecord::Migration.suppress_messages { described_class.new.migrate(direction) }
  end

  def scopes_of(record)
    JSON.parse(record.reload.data['scopes'])
  end

  def request_from(form_uid, *traits)
    create(:authorization_request, form_uid.tr('-', '_').to_sym, *traits, scopes: existing_scopes)
  end

  def authorization_from(form_uid, state: 'active')
    authorization = create(:authorization, authorization_request_trait: form_uid.tr('-', '_').to_sym)
    authorization.update_columns(form_uid:, state:, data: authorization.data.merge('scopes' => existing_scopes.to_json))
    authorization
  end

  describe 'up' do
    it 'adds only the foundations base data to a request made with the api-entreprise-socle-de-base form' do
      request = request_from('api-entreprise-socle-de-base', :submitted)

      migrate(:up)

      expect(scopes_of(request)).to contain_exactly(*existing_scopes, fondations_scope)
    end

    described_class::ACCOUNTS_FORM_UIDS.each do |form_uid|
      it "adds the foundations base data and accounts to a request made with the #{form_uid} form" do
        request = request_from(form_uid, :submitted)

        migrate(:up)

        expect(scopes_of(request)).to contain_exactly(*existing_scopes, fondations_scope, comptes_scope)
      end

      it "adds the foundations base data and accounts to an authorization of the #{form_uid} form" do
        authorization = authorization_from(form_uid)

        migrate(:up)

        expect(scopes_of(authorization)).to contain_exactly(*existing_scopes, fondations_scope, comptes_scope)
      end
    end

    it 'adds the foundations base data to a draft request of a use case form' do
      request = request_from('api-entreprise-socle-de-base', :draft)

      migrate(:up)

      expect(scopes_of(request)).to include(fondations_scope)
    end

    %w[active revoked obsolete].each do |state|
      it "adds the foundations base data to an #{state} authorization of a use case form" do
        authorization = authorization_from('api-entreprise-socle-de-base', state:)

        migrate(:up)

        expect(scopes_of(authorization)).to contain_exactly(*existing_scopes, fondations_scope)
      end
    end

    %w[api-entreprise api-entreprise-editeur api-entreprise-portail-gru-instruction].each do |form_uid|
      it "leaves a request made with the #{form_uid} form untouched" do
        request = request_from(form_uid, :submitted)

        migrate(:up)

        expect(scopes_of(request)).to match_array(existing_scopes)
      end

      it "leaves an authorization of the #{form_uid} form untouched" do
        authorization = authorization_from(form_uid)

        migrate(:up)

        expect(scopes_of(authorization)).to match_array(existing_scopes)
      end
    end

    it 'leaves an authorization whose form is unknown untouched' do
      authorization = authorization_from('api-entreprise-socle-de-base')
      authorization.update_column(:form_uid, nil)

      migrate(:up)

      expect(scopes_of(authorization)).to match_array(existing_scopes)
    end

    it 'does not attribute the foundations scopes to the applicant on their next submission' do
      request = request_from('api-entreprise-detection-fraude', :submitted)

      migrate(:up)
      changelog = CreateAuthorizationRequestChangelog.call(authorization_request: request.reload).changelog

      expect(changelog.diff).not_to have_key('scopes')
    end

    it 'does not make a reopened authorization of a use case form look modified when the applicant changed nothing' do
      authorization = authorization_from('api-entreprise-marches-publics')
      request = authorization.request
      request.update_column(:data, request.data.merge('scopes' => existing_scopes.to_s))
      authorization.update_column(:data, request.data)

      migrate(:up)
      request.reload.scopes = request.scopes
      request.save!(validate: false)

      expect(ReopeningChangesChecker.new(request.reload)).not_to be_changed
    end

    it 'does not duplicate the foundations scopes when run twice' do
      request = request_from('api-entreprise-marches-publics', :draft)

      2.times { migrate(:up) }

      expect(scopes_of(request).tally.values_at(fondations_scope, comptes_scope)).to eq([1, 1])
    end
  end

  describe 'down' do
    it 'removes the foundations scopes and keeps the other scopes' do
      request = request_from('api-entreprise-aides-publiques', :submitted)
      migrate(:up)

      migrate(:down)

      expect(scopes_of(request)).to match_array(existing_scopes)
    end

    it 'keeps the foundations scopes chosen by the applicant in another form' do
      request = create(:authorization_request, :api_entreprise, :submitted, scopes: existing_scopes + [fondations_scope, comptes_scope])
      migrate(:up)

      migrate(:down)

      expect(scopes_of(request)).to include(fondations_scope, comptes_scope)
    end
  end
end

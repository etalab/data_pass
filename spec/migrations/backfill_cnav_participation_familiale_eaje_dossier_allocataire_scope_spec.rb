require 'rails_helper'
require Rails.root.join('db/migrate/20261113100000_backfill_cnav_participation_familiale_eaje_dossier_allocataire_scope.rb')

RSpec.describe BackfillCnavParticipationFamilialeEajeDossierAllocataireScope do
  let(:dossier_allocataire_scope) { 'cnav_participation_familiale_eaje_dossier_allocataire' }
  let(:eaje_scopes) { described_class::EAJE_SCOPES }

  def migrate(direction)
    ActiveRecord::Migration.suppress_messages { described_class.new.migrate(direction) }
  end

  def with_scopes(record, scopes)
    record.tap { |r| r.update_column(:data, r.data.merge('scopes' => scopes.to_json)) }
  end

  def scopes_of(record)
    JSON.parse(record.reload.data['scopes'])
  end

  def eaje_request(*traits)
    with_scopes(create(:authorization_request, :api_particulier, *traits), eaje_scopes)
  end

  def eaje_authorization(state)
    authorization = create(:authorization, authorization_request_trait: :api_particulier)
    authorization.update_column(:state, state)
    with_scopes(authorization, eaje_scopes)
  end

  describe 'up' do
    it 'adds the dossier allocataire scope to a draft EAJE request' do
      request = eaje_request(:draft)

      migrate(:up)

      expect(scopes_of(request)).to contain_exactly(*eaje_scopes, dossier_allocataire_scope)
    end

    it 'adds the dossier allocataire scope to a submitted EAJE request' do
      request = eaje_request(:submitted)

      migrate(:up)

      expect(scopes_of(request)).to contain_exactly(*eaje_scopes, dossier_allocataire_scope)
    end

    it 'adds the dossier allocataire scope to a request carrying only part of the EAJE scopes' do
      request = with_scopes(create(:authorization_request, :api_particulier), %w[cnav_participation_familiale_eaje_enfants])

      migrate(:up)

      expect(scopes_of(request)).to contain_exactly('cnav_participation_familiale_eaje_enfants', dossier_allocataire_scope)
    end

    it 'adds the dossier allocataire scope to an EAJE request made through Démarche numérique' do
      request = with_scopes(create(:authorization_request, :api_particulier_demarche_numerique), eaje_scopes)

      migrate(:up)

      expect(scopes_of(request)).to include(dossier_allocataire_scope)
    end

    %w[active revoked obsolete].each do |state|
      it "adds the dossier allocataire scope to an #{state} EAJE authorization" do
        authorization = eaje_authorization(state)

        migrate(:up)

        expect(scopes_of(authorization)).to contain_exactly(*eaje_scopes, dossier_allocataire_scope)
      end
    end

    it 'leaves a request without EAJE scopes untouched' do
      request = with_scopes(create(:authorization_request, :api_particulier), %w[cnaf_quotient_familial])

      migrate(:up)

      expect(scopes_of(request)).to eq(%w[cnaf_quotient_familial])
    end

    it 'does not attribute the added scope to the applicant on their next submission' do
      request = create(:authorization_request, :api_particulier, :submitted, scopes: eaje_scopes)

      migrate(:up)
      changelog = CreateAuthorizationRequestChangelog.call(authorization_request: request.reload).changelog

      expect(changelog.diff).not_to have_key('scopes')
    end

    it 'keeps an unsubmitted scope change of the applicant in their next submission history' do
      request = create(:authorization_request, :api_particulier, :submitted, scopes: eaje_scopes)
      request.scopes = eaje_scopes + %w[cnaf_quotient_familial]
      request.save!(validate: false)

      migrate(:up)
      changelog = CreateAuthorizationRequestChangelog.call(authorization_request: request.reload).changelog

      expect(changelog.diff['scopes']).to eq([
        (eaje_scopes + [dossier_allocataire_scope]).sort,
        (eaje_scopes + [dossier_allocataire_scope, 'cnaf_quotient_familial']).sort
      ])
    end

    it 'does not make a reopened EAJE authorization look modified when the applicant changed nothing' do
      authorization = create(:authorization, authorization_request_trait: :api_particulier)
      request = authorization.request
      request.update_column(:data, request.data.merge('scopes' => eaje_scopes.to_s))
      authorization.update_column(:data, request.data)

      migrate(:up)
      request.reload.scopes = request.scopes
      request.save!(validate: false)

      expect(ReopeningChangesChecker.new(request.reload)).not_to be_changed
    end

    it 'does not duplicate the scope when run twice' do
      request = eaje_request(:draft)

      2.times { migrate(:up) }

      expect(scopes_of(request).count(dossier_allocataire_scope)).to eq(1)
    end
  end

  describe 'down' do
    it 'removes the dossier allocataire scope and keeps the other EAJE scopes' do
      request = eaje_request(:draft)
      migrate(:up)

      migrate(:down)

      expect(scopes_of(request)).to match_array(eaje_scopes)
    end
  end
end

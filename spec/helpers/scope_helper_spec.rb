require 'rails_helper'

RSpec.describe ScopeHelper do
  describe '#scope_groups_for_display' do
    def scope(name:, value:, group: nil, provider_label: nil)
      AuthorizationDefinition::Scope.new(name:, value:, group:, provider_label:)
    end

    it 'groups scopes by the provider+group pair and joins both into the heading' do
      scopes = [
        scope(name: 'Quotient familial CAF & MSA', value: 'cnaf_quotient_familial', group: 'API Quotient familial', provider_label: 'CNAF & MSA'),
        scope(name: 'Identités allocataire et conjoint', value: 'cnaf_allocataires', group: 'API Quotient familial', provider_label: 'CNAF & MSA'),
      ]

      result = helper.scope_groups_for_display(scopes)

      expect(result.size).to eq(1)
      expect(result.first.heading).to eq('CNAF & MSA — API Quotient familial')
      expect(result.first.scopes).to eq(scopes)
    end

    it 'uses the provider alone as heading when group is absent' do
      scopes = [scope(name: 'Nom de naissance', value: 'family_name', provider_label: 'FranceConnect')]

      result = helper.scope_groups_for_display(scopes)

      expect(result.first.heading).to eq('FranceConnect')
    end

    it 'uses the group alone as heading when provider is absent (unchanged behavior for every other API)' do
      scopes = [scope(name: 'Nom de famille', value: 'family_name', group: 'Identité pivot')]

      result = helper.scope_groups_for_display(scopes)

      expect(result.first.heading).to eq('Identité pivot')
    end

    it 'returns a blank heading when neither provider nor group is set' do
      scopes = [scope(name: 'Nom de famille', value: 'family_name')]

      result = helper.scope_groups_for_display(scopes)

      expect(result.first.heading).to be_nil
    end

    it 'splits scopes with the same group but different providers into separate display groups' do
      scopes = [
        scope(name: 'A', value: 'a', group: 'Informations générales', provider_label: 'INSEE'),
        scope(name: 'B', value: 'b', group: 'Informations générales', provider_label: 'Infogreffe'),
      ]

      result = helper.scope_groups_for_display(scopes)

      expect(result.map(&:heading)).to eq(['INSEE — Informations générales', 'Infogreffe — Informations générales'])
    end
  end
end

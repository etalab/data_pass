require 'rails_helper'

RSpec.describe ContactDefinition do
  describe '#fill_data_with_applicant_data?' do
    it 'returns true for contact types in FILLABLE_WITH_APPLICANT_DATA_TYPES' do
      contact_definition = described_class.new(:contact_metier)
      expect(contact_definition.fill_data_with_applicant_data?).to be(true)

      contact_definition = described_class.new(:contact_technique)
      expect(contact_definition.fill_data_with_applicant_data?).to be(true)

      contact_definition = described_class.new(:administrateur_metier)
      expect(contact_definition.fill_data_with_applicant_data?).to be(true)
    end

    it 'returns false for contact types not in FILLABLE_WITH_APPLICANT_DATA_TYPES' do
      contact_definition = described_class.new(:responsable_traitement)
      expect(contact_definition.fill_data_with_applicant_data?).to be(false)

      contact_definition = described_class.new(:delegue_protection_donnees)
      expect(contact_definition.fill_data_with_applicant_data?).to be(false)
    end

    it 'allows override through options' do
      contact_definition = described_class.new(:responsable_traitement, fillable_with_applicant_data: true)
      expect(contact_definition.fill_data_with_applicant_data?).to be(true)

      contact_definition = described_class.new(:contact_metier, fillable_with_applicant_data: false)
      expect(contact_definition.fill_data_with_applicant_data?).to be(false)
    end
  end

  describe '#required_personal_email?' do
    it 'returns false by default' do
      contact_definition = described_class.new(:contact_metier)
      expect(contact_definition.required_personal_email?).to be(false)
    end

    it 'returns the value from options if provided' do
      contact_definition = described_class.new(:contact_metier, required_personal_email: true)
      expect(contact_definition.required_personal_email?).to be(true)
    end
  end
end

require 'rails_helper'

RSpec.describe Contact do
  let(:authorization_request) do
    build(:authorization_request, :api_particulier,
      contact_technique_family_name: 'Dupont',
      contact_technique_given_name: 'Jean',
      contact_technique_email: 'jean.dupont@example.com',
      contact_technique_phone_number: '0612345678',
      contact_technique_job_title: 'Developer')
  end

  let(:contact) { described_class.new(:contact_technique, authorization_request) }

  describe '#to_attributes' do
    context 'without prefix' do
      it 'returns attributes hash without prefix' do
        result = contact.to_attributes

        expect(result).to eq(
          family_name: 'Dupont',
          given_name: 'Jean',
          email: 'jean.dupont@example.com',
          phone_number: '0612345678',
          job_title: 'Developer'
        )
      end
    end

    context 'with prefix' do
      it 'returns attributes hash with prefix' do
        result = contact.to_attributes(prefix: :contact_metier)

        expect(result).to eq(
          contact_metier_family_name: 'Dupont',
          contact_metier_given_name: 'Jean',
          contact_metier_email: 'jean.dupont@example.com',
          contact_metier_phone_number: '0612345678',
          contact_metier_job_title: 'Developer'
        )
      end
    end

    context 'with nil values' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier,
          contact_technique_family_name: 'Dupont',
          contact_technique_given_name: nil,
          contact_technique_email: 'jean.dupont@example.com')
      end

      it 'excludes nil values from hash' do
        result = contact.to_attributes

        expect(result).to eq(
          family_name: 'Dupont',
          email: 'jean.dupont@example.com'
        )
        expect(result).not_to have_key(:given_name)
        expect(result).not_to have_key(:phone_number)
        expect(result).not_to have_key(:job_title)
      end
    end

    context 'with empty string values' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier,
          contact_technique_family_name: 'Dupont',
          contact_technique_given_name: '',
          contact_technique_email: 'jean.dupont@example.com')
      end

      it 'excludes empty string values from hash' do
        result = contact.to_attributes

        expect(result).to eq(
          family_name: 'Dupont',
          email: 'jean.dupont@example.com'
        )
        expect(result).not_to have_key(:given_name)
      end
    end
  end
end

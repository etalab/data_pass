# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Datagouv::GenerateHabilitationsCsv do
  subject(:result) { described_class.call(rows: rows) }

  let(:rows) do
    [
      ['APIEntreprise', 'ACME', '12345678901234', 'scope1', 'DINUM', 'Loi', '2025-01-15'],
      ['ApiParticulier', 'Org2', '', 'scope2', '', '', '2024-06-01']
    ]
  end

  after do
    File.delete(result.csv_path) if result.csv_path.present? && File.exist?(result.csv_path)
  end

  it 'succeeds' do
    expect(result).to be_success
  end

  it 'writes a CSV file with headers and rows' do
    content = File.read(result.csv_path)

    expect(content).to include('API ou Service demandé')
    expect(content).to include("Dénomination de l'unité légale du demandeur")
    expect(content).to include('SIRET du demandeur')
    expect(content).to include('Données demandées')
    expect(content).to include("Fournisseur de l'API ou service")
    expect(content).to include('Fondement juridique')
    expect(content).to include('Date de validation')
    expect(content).to include('APIEntreprise')
    expect(content).to include('ACME')
    expect(content).to include('12345678901234')
    expect(content).to include('scope1')
    expect(content).to include('DINUM')
    expect(content).to include('Loi')
    expect(content).to include('2025-01-15')
  end
end

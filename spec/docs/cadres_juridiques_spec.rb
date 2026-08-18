# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'docs/api_particulier/cadres_juridiques.md' do
  subject(:documentation) { Rails.root.join('docs/api_particulier/cadres_juridiques.md').read }

  let(:configured_form_uids) do
    AuthorizationRequestFormConfigurations.instance.all.select { |_uid, config|
      config.deep_symbolize_keys[:authorization_request].to_s == 'APIParticulier'
    }.keys.map(&:to_s)
  end

  let(:documented_form_uids) { sections.values.flat_map { |section| section[:form_uids] } }

  let(:sections) do
    documentation.split(/^### /).drop(1).to_h do |section|
      header, *rows = section.lines
      label, declared_count = header.match(/\A(.+?) — (\d+) formulaire/).captures

      [label, { declared_count: declared_count.to_i, form_uids: rows.filter_map { |row| row[/\| `([a-z0-9-]+)` \|$/, 1] } }]
    end
  end

  let(:summary_counts) do
    documentation.scan(/^\| \*\*(.+?)\*\* \| `\w+` \| (\d+) \|/).to_h { |label, count| [label, count.to_i] }
  end

  it 'documents every API Particulier form' do
    missing = configured_form_uids - documented_form_uids

    expect(missing).to be_empty,
      "#{missing.size} formulaire(s) absent(s) de la documentation :\n#{missing.map { |uid| "  #{uid}" }.join("\n")}"
  end

  it 'does not document unknown forms' do
    orphans = documented_form_uids - configured_form_uids

    expect(orphans).to be_empty,
      "#{orphans.size} formulaire(s) documenté(s) mais absent(s) de la configuration :\n#{orphans.map { |uid| "  #{uid}" }.join("\n")}"
  end

  it 'announces the actual number of forms in each section' do
    mismatches = sections.filter_map do |label, section|
      next if section[:declared_count] == section[:form_uids].size

      "  #{label} : #{section[:declared_count]} annoncé(s), #{section[:form_uids].size} listé(s)"
    end

    expect(mismatches).to be_empty, "Compteurs de section incorrects :\n#{mismatches.join("\n")}"
  end

  it 'keeps the summary table consistent with the sections' do
    mismatches = summary_counts.filter_map do |label, count|
      listed = sections.fetch(label)[:form_uids].size
      next if count == listed

      "  #{label} : #{count} dans le tableau de synthèse, #{listed} listé(s)"
    end

    expect(mismatches).to be_empty, "Tableau de synthèse désynchronisé :\n#{mismatches.join("\n")}"
  end
end

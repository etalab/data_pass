require 'rails_helper'

RSpec.describe 'Page titles coverage' do
  describe 'all routes have specific page titles' do
    let(:routes_to_skip) do
      [
        '/rails/',
        '/api/',
        '/oauth/',
        '/errors/',
        '/demandes/:id',
        '/habilitations/:id',
      ]
    end

    def normalize_title(title)
      title.gsub(/\s+/, ' ').strip
    end

    # rubocop:disable RSpec/NoExpectationExample
    it 'checks that all public GET routes have a specific page title' do
      routes = Rails.application.routes.routes
        .select { |r| r.verb.include?('GET') }
        .map { |r| r.path.spec.to_s.gsub(/\([^)]*\)/, '') }
        .compact_blank
        .reject { |path| routes_to_skip.any? { |skip| path.start_with?(skip) } }
        .reject { |path| path.include?(':') }
        .uniq
        .sort

      missing_titles = []

      routes.each do |route|
        visit route

        next if page.has_content?('Se connecter') || page.has_content?('ProConnect')

        title = normalize_title(page.find('title', visible: false).text(:all))

        if title == 'DataPass'
          missing_titles << route
        elsif !title.end_with?(' - DataPass')
          missing_titles << "#{route} (format incorrect: '#{title}')"
        end
      rescue ActionController::RoutingError, ActiveRecord::RecordNotFound, Capybara::ElementNotFound, TypeError
        next
      end

      if missing_titles.any?
        error_message = <<~ERROR
          The following routes are missing specific page titles:

          #{missing_titles.map { |r| "  - #{r}" }.join("\n")}

          All pages must have a title ending with ' - DataPass' and not just 'DataPass'.

          To fix this, add a page title using:
          1. In the view: <% provide_title t('.page_title') %>
          2. In the locale: Add the translation to config/locales/page_titles.fr.yml
        ERROR

        fail error_message
      end
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe 'authenticated routes' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before do
      user.organizations << organization
      sign_in(user)
    end

    it 'checks that authenticated routes have specific page titles' do
      authenticated_routes = {
        '/tableau-de-bord' => /Tableau de bord/,
        '/compte' => /Votre compte/,
      }

      authenticated_routes.each do |route, expected_pattern|
        visit route
        title = page.find('title', visible: false).text(:all)

        expect(title).to match(expected_pattern),
          "Route #{route} has unexpected title: '#{title}'"
        expect(title).to end_with(' - DataPass'),
          "Route #{route} title doesn't end with ' - DataPass': '#{title}'"
      end
    end
  end
end

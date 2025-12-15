RSpec.describe 'JavaScript errors', :js do
  let(:user) { create(:user) }

  before do
    WebMock.allow_net_connect!
    sign_in(user)
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'does not produce JS errors on dashboard page' do
    errors = []
    page.driver.browser.on('Runtime.exceptionThrown') do |params|
      errors << params.dig('exceptionDetails', 'exception', 'description')
    end

    visit dashboard_path

    expect(errors).to be_empty, "JS errors found: #{errors.join(', ')}"
  end
end

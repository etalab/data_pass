require 'capybara/cuprite'

return if Kernel.const_defined?(:REMOTE_CHROME_URL)

REMOTE_CHROME_URL = ENV.fetch('CHROME_URL', nil)
REMOTE_CHROME_HOST, REMOTE_CHROME_PORT =
  if REMOTE_CHROME_URL
    URI.parse(REMOTE_CHROME_URL).then do |uri|
      [uri.host, uri.port]
    end
  end

# Check whether the remote chrome is running.
remote_chrome =
  begin
    if REMOTE_CHROME_URL.nil?
      false
    else
      Socket.tcp(REMOTE_CHROME_HOST, REMOTE_CHROME_PORT, connect_timeout: 1).close
      true
    end
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
    false
  end

remote_options = remote_chrome ? { ws_url: REMOTE_CHROME_URL } : {}

inspector = ENV['INSPECTOR'] == 'true'

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  browser_options = {
    'disable-gpu' => nil,
    'disable-dev-shm-usage' => nil,
    'disable-setuid-sandbox' => nil,
  }.tap do |opts|
    opts['no-sandbox'] = nil if remote_chrome
  end

  Capybara::Cuprite::Driver.new(
    app,
    browser_options:,
    inspector:,
    flatten: false,
    process_timeout: 12,
    timeout: 2,
    headless: !inspector && ENV['HEADLESS'] != 'false', **remote_options
  )
end
Capybara.server = :puma, { Silent: true }
Capybara.server_host = '0.0.0.0'
Capybara.always_include_port = true
Capybara.app_host = "http://#{ENV.fetch('APP_HOST', `hostname`.strip&.downcase || '0.0.0.0')}" if remote_chrome
Capybara.default_max_wait_time = 2

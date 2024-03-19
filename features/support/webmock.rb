require 'webmock/cucumber'

WebMock.disable_net_connect!(allow_localhost: true, allow: 'http://chrome:3333')

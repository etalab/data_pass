if Rails.env.test? || Rails.env.development?
  require 'parallel_tests/tasks'
end

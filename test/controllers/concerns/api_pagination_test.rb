require 'test_helper'

class APIPaginationTest < ActiveSupport::TestCase
  class DummyController
    include APIPagination
  end

  setup do
    @controller = DummyController.new
  end

  test 'returns the requested limit when below the maximum' do
    assert_equal 50, @controller.limit_records(50)
  end

  test 'returns the default limit when no limit is specified' do
    assert_equal 10, @controller.limit_records(nil)
  end

  test 'returns the default limit when limit is not a positive integer' do
    assert_equal 10, @controller.limit_records(0)
    assert_equal 10, @controller.limit_records(-1)
    assert_equal 10, @controller.limit_records('invalid')
  end

  test 'returns the maximum limit when limit exceeds the maximum' do
    assert_equal APIPagination::MAX_LIMIT, @controller.limit_records(APIPagination::MAX_LIMIT + 1)
    assert_equal APIPagination::MAX_LIMIT, @controller.limit_records(9999)
  end

  test 'accepts a custom default limit' do
    assert_equal 25, @controller.limit_records(nil, 25)
  end
end

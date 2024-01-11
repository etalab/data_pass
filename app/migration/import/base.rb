class Import::Base
  include ImportUtils

  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def perform
    raise NotImplementedError
  end

  def import?(row)
    true
  end
end

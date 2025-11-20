class EligibilityRule < ActiveYaml::Base
  include Draper::Decoratable

  set_root_path 'db/data'
  set_filename 'eligibility_rules'

  def options
    @options ||= read_attribute(:options).map { |option_hash| EligibilityOption.new(option_hash) }
  end
end

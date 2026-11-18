RSpec::Matchers.define_negated_matcher :not_change, :change

module LateFailureHelpers
  class LateFailure < StandardError; end

  FAILURE_MODES = {
    'context.fail!' => :fail,
    'an exception' => :raise,
  }.freeze

  def make_step_fail(interactor, mode)
    if mode == :fail
      allow(interactor).to receive(:call!) { |context| context.fail!(error: :late_failure) }
    else
      allow(interactor).to receive(:call!).and_raise(LateFailure)
    end
  end

  def call_through_late_failure
    yield
  rescue LateFailure
    nil
  end
end

RSpec.configure do |config|
  config.include LateFailureHelpers
end

RSpec::Matchers.define :have_valid_syntax do
  match do |file|
    syntax_valid?(file.read)
  end

  failure_message do |file|
    "expected that the file '#{file}' would have valid Ruby syntax"
  end

  failure_message_when_negated do |file|
    "expected that the file '#{file}' would not have valid Ruby syntax"
  end

  # rubocop:disable Security/Eval, Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
  def syntax_valid?(code)
    eval("__crash_me__;#{code}")
  rescue SyntaxError
    false
  rescue NameError
    true
  end
  # rubocop:enable Security/Eval, Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
end

module APIScopes
  BY_ACTION = {
    'submission' => 'submit_authorizations',
    'validation' => 'validate_authorizations',
  }.freeze

  ALL = BY_ACTION.values.freeze
end

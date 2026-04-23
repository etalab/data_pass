module RoleHierarchy
  IMPLIES = {
    manager: %i[instructor reporter],
    instructor: %i[reporter],
    developer: %i[reporter],
    reporter: [],
  }.freeze

  def self.qualifying_roles(kind)
    kind = kind.to_sym
    result = [kind]
    IMPLIES.each { |role, implied| result << role if implied.include?(kind) }
    result.map(&:to_s)
  end
end

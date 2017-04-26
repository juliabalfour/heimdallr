class JwtApplication < ApplicationRecord
  has_many :jwt_tokens

  validates :name,  uniqueness: true
  validates :key,   uniqueness: true

  # Gets the scopes for this model
  #
  # @return [Auth::Scopes]
  def scopes
    Auth::Scopes.from_string(self[:scopes])
  end

  # Gets the scope string for this model
  #
  # @return [String]
  def scopes_string
    self[:scopes]
  end

  # Checks whether or not this model has specific scopes
  #
  # @param required_scopes [Array] The scopes to check for.
  # @return [Boolean]
  def includes_scope?(*required_scopes)
    required_scopes.blank? || required_scopes.any? { |scope| scopes.exists?(scope.to_s) }
  end
end

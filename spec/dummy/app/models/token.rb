class Token < ApplicationRecord
  include Heimdallr::TokenMixin
  include Heimdallr::Models::Revocable
  include Heimdallr::Models::Refreshable

  belongs_to :application
end

module Heimdallr
  class Token < ApplicationRecord
    belongs_to :application
  end
end

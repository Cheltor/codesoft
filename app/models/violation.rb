class Violation < ApplicationRecord
  belongs_to :address

  enum status: [:current, :resolved]

  
end

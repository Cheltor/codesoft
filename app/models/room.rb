class Room < ApplicationRecord
    has_many :prompts, dependent: :destroy

    validates :name, presence: true, uniqueness: true
end

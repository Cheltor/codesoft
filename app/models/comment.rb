class Comment < ApplicationRecord
  belongs_to :address
  belongs_to :user
end
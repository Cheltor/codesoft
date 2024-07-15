class CitationComment < ApplicationRecord
  belongs_to :user
  belongs_to :citation
  has_many_attached :photos
  has_paper_trail
end

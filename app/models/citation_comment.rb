class CitationComment < ApplicationRecord
  belongs_to :user
  belongs_to :citation
end

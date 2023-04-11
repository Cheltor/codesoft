class CitationCode < ApplicationRecord
  belongs_to :citation
  belongs_to :code
end
